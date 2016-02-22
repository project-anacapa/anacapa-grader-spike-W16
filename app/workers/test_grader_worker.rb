class TestGraderWorker

	require 'net/ssh'
  	require 'net/ssh/shell'

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
    
    	worker = WorkerMachine.getTestWorkerMachine()
    	Net::SSH.start(worker.host, worker.user,
            :port => worker.port,
            :keys => [],
            :key_data => [worker.privateKey],
            :keys_only => TRUE) do |ssh|

      	ssh.shell do |sh|
        	sh.execute "mkdir anacapaTest"
        	sh.execute "cd anacapaTest"
        	sh.execute "git clone #{url}"
        	sh.execute "git clone #{expectedURL}"

        	sh.execute "cd expected-lab01"
        	process = sh.execute "cat .gitignore"
        	# process.on_output do |proc, output|
        	# 	puts "PREPARE FOR KEK"
        	# 	puts "PROCESS: #{proc}"
        	# 	puts output
        	# 	puts "KEK OVER" 
        	# end

        	sh.close
      	end

      	# ssh.loop
    	end
	end

	def cloneRepo(ssh, url)

	end

	def self.job_name(payload)
		"Grading"
	end
end