class TestGraderWorker

	require 'net/ssh'
  	require 'net/ssh/shell'
    require 'git'

	include Sidekiq::Worker

	def perform(payload)
		url = payload["repository"]["url"]
    	commitHash = payload["head_commit"]["id"]

    	path = URI.parse(url).path
    	fields = /\/(.+)\/(?:(.+)-)?(.*)-(.*)/.match(path)
    	organization = fields[1]

    	expectedURL = "https://github.com/#{organization}/expected-lab01.git"
        studentURL = "#{url}.git"
        gradeURL = "https://github.com/#{organization}/grades-#{payload["pusher"]["name"]}.git"

        Dir.mktmpdir do |dir|
            puts "CREATED TEMP DIR: #{dir}"

            expected = Git.clone(expectedURL, "expected", :path => "#{dir}/repos")
            student = Git.clone(studentURL, "student", :path => "#{dir}/repos")
            grade = Git.clone(gradeURL, "grades", :path => "#{dir}/repos")

            gradeStudentCode("#{dir}/repos")
            FileUtils.rm_rf("#{dir}/repos")

            puts "Done!"
        end
	end

	def gradeStudentCode(dir)
        puts "Generating results..."

        machine = WorkerMachine.getTestWorkerMachine()
        testables = nil
        Net::SSH.start(machine.host, machine.user,
                        :port => machine.port,
                        :keys => [],
                        :key_data => [machine.privateKey],
                        :keys_only => TRUE) do |ssh|

            killAllProcesses(ssh)
            cleanupWorkspace(ssh)
            initializeWorkspace(ssh)
            copyWorkspace(machine, dir)

            results = processTestables(ssh, dir)
            generateGrade(dir, results)

            killAllProcesses(ssh)
            cleanupWorkspace(ssh)
            ssh.close
        end
    end

    def killAllProcesses(ssh)
        #killall processes execpt those returned by
        # ps T selects all processes and threads that belong to the current terminal
        # -N negates it
        puts "Killing all processes..."

        ssh.exec! "kill -9 `ps -o pid= -N T`"
        ssh.loop
    end

    def initializeWorkspace(ssh)
        puts "Initializing workspace and entering..."

        ssh.exec! "rm -rf anacapa_grader_workspace"
        ssh.exec! "mkdir -p anacapa_grader_workspace"
        ssh.loop
    end

    def copyWorkspace(machine, dir)
        puts "Copying workspace..."

        ssh = {:port => machine.port, :key_data => machine.privateKey}
        Net::SCP.upload!(machine.host, machine.user, 
                         "#{dir}/student", "anacapa_grader_workspace/student_files/",
                         :recursive => TRUE,
                         :ssh => ssh)
    end

    def cleanupWorkspace(ssh)
        puts "Cleaning up workspace..."

        ssh.exec! "rm -rf anacapa_grader_workspace"
        ssh.loop
    end

    def processTestables(ssh, dir)
        jsonDir = "#{dir}/expected/expected.json"
        testables = JSON.parse(File.read(jsonDir))

        testables["testables"].each do |testable|
            buildCommand = testable["build_command"]
            buildTimeout = testable["build_timeout"]
            expectedBuildOutput = testable["make_output"]["make_output"]

            puts "Building: #{buildCommand}"
            buildOutput = ssh.exec! "cd anacapa_grader_workspace/student_files; #{buildCommand}"
            if buildOutput == expectedBuildOutput
                puts "Build output: #{buildOutput}"
                testable["test_cases"].each do |testCase|
                    runTestCase(testCase, ssh)
                    # killAllProcesses(ssh)
                end
            else
                puts "\"#{buildCommand}\" failed, all test cases failed"
                testable["build_command"] = buildOutput
            end
        end

        ssh.loop
        return testables
    end

    def runTestCase(testCase, ssh)
        command = testCase["command"]
        points = testCase["points"]
        executeTimeout = testCase["execute_timeout"]

        begin
            timeout executeTimeout do
                puts "\tRunning: #{command}, timeout: #{executeTimeout}"
                
                output = ssh.exec! "cd anacapa_grader_workspace/student_files; #{command}"

                puts "\t\tOutput: #{output}"
                puts "\t\tExpect: #{testCase["output"]}"

                if output == testCase["output"]
                    puts "\t\t#{points}/#{points} points"
                else
                    puts "\t\t0/#{points} points"
                    testCase["points"] = 0
                end

                testCase["output"] = output
            end
        rescue Timeout::Error
            # TODO: Kill processes gracefully
            puts "\tCommand timed out, 0/#{points} points"
         end
    end

    def generateGrade(dir, results)
        puts "Generating grade..."

        gradesRepo = Git.open("#{dir}/grades")
        assignmentDir = "#{dir}/grades/test_assignment"

        if !Dir.exists?(assignmentDir)
            Dir.mkdir("#{dir}/grades/test_assignment")
        end

        File.open("#{assignmentDir}/README.md", "w") do |file|
            puts "Writing grade info to file..."
            writeGradeInfoIntoFile(file, results)
            file.close
        end

        puts "Committing and pushing grade..."
        gradesRepo.config("user.name", "anacapa-test")
        gradesRepo.config("user.email", Key.graderEmail())

        begin
            gradesRepo.add
            gradesRepo.commit("Anacapa Grader: Grade for test_assignment")
            gradesRepo.push
            puts "Grade pushed!"
        rescue
            puts "Error committing grade file!"
        end
    end

    def writeGradeInfoIntoFile(file, results)
        file.write("# Grade\n")
            results["testables"].each do |testable|
                file.write("## #{testable["build_command"]}\n")
                file.write("| Test | Points |\n")
                file.write("| ---- | ------ |\n")

                testable["test_cases"].each do |testCase|
                file.write("| #{testCase["command"]} | #{testCase["points"]} |\n")
            end
        end

        curTime = Time.new
        file.write("Graded at #{curTime.inspect}")
    end

	def self.job_name(payload)
		"Grading"
	end
end