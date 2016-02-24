class TestGraderWorker

	require 'net/ssh'
  	require 'net/ssh/shell'
    require 'git'

	include Sidekiq::Worker

	def perform(payload)
		# clone student repo
		# clone expected repo
		# get expected json back onto server
		# run student code
		# get student output back onto server

		url = payload["repository"]["url"]
    	commitHash = payload["head_commit"]["id"]

    	path = URI.parse(url).path
    	fields = /\/(.+)\/(?:(.+)-)?(.*)-(.*)/.match(path)
    	organization = fields[1]

    	expectedURL = "https://github.com/#{organization}/expected-lab01.git"
        studentURL = "#{url}.git"

        # Dir.mktmpdir do |dir|
            # puts "CREATED TEMP DIR: #{dir}"
            expected = Git.clone(expectedURL, "expected", :path => "repos")
            student = Git.clone(studentURL, "student", :path => "repos")
            generateResults("repos")
            FileUtils.rm_rf("repos")
            puts "Done!"
        # end
	end

	def generateResults(dir)
        puts "Generating results..."

        machine = WorkerMachine.getTestWorkerMachine()
        testables = nil
        Net::SSH.start(machine.host, machine.user,
                        :port => machine.port,
                        :keys => [],
                        :key_data => [machine.privateKey],
                        :keys_only => TRUE) do |ssh|

            killAllProcesses(ssh)
            initializeWorkspace(ssh)
            copyWorkspace(machine, dir)
            # run code
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
    end

	def self.job_name(payload)
		"Grading"
	end
end