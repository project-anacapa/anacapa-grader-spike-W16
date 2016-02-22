class GithubWebhooksController < ApplicationController
  
	include GithubWebhook::Processor
  # require 'net/ssh'
  # require 'net/ssh/shell'

	# skip_before_filter :verify_authenticity_token, :only => [:index]

	def github_push(payload)

    # TestGraderWorker.perform_async(payload)
    TestGraderWorker.perform_async(payload)

    # clone student repo
    # clone expected repo
    # get expected json back onto server
    # run student code
    # get student output back onto server

    # url = payload["repository"]["url"]
    # commitHash = payload["head_commit"]["id"]

    # path = URI.parse(url).path
    # fields = /\/(.+)\/(?:(.+)-)?(.*)-(.*)/.match(path)
    # organization = fields[1]

    # expectedURL = "https://github.com/#{organization}/expected-lab01.git" 
    
    # worker = WorkerMachine.getTestWorkerMachine()
    # Net::SSH.start(worker.host, worker.user,
    #         :port => worker.port,
    #         :keys => [],
    #         :key_data => [worker.privateKey],
    #         :keys_only => TRUE) do |ssh|

    #   ssh.shell do |sh|
    #     sh.execute "mkdir anacapaTest"
    #     sh.execute "cd anacapaTest"
    #     sh.execute "git clone #{expectedURL}"
    #   end

    #   ssh.loop
    # end


		# Rails.application.config.logger.info "~~~~~ THERE WAS A PUSH! ~~~~~"
		# TestGraderWorker.perform_async(payload)

  #   url = payload["repository"]["url"]
  #   version = payload["head_commit"]["id"]

  #   path = URI.parse(url).path
  #   fields =  /\/(.+)\/(?:(.+)-)?(.*)-(.*)/.match(path)

  #   org = fields[1]

  #   if fields[2] == nil
  #     if fields[3] == 'grader'
  #       type = 'grader'
  #       project = fields[4]
  #     elsif fields[3] == 'expected'
  #       type = 'expected'
  #       project = fields[4]
  #     else
  #       type = 'submission'
  #       project = fields[3]
  #       user    = fields[4]
  #     end
  #   else
  #     type    = fields[2]
  #     project = fields[3]
  #     user    = fields[4]
  #   end



  #   organization = Organization.find_by name: org

  #   instructor_token = organization.user.token
  #   student_repo_short = "#{project}-#{user}"
  #   student_repo     = "#{org}/#{student_repo_short}"
  #   student_url      = "https://#{instructor_token}@github.com/#{student_repo}.git"
  #   grader_repo      = "#{org}/grader-#{project}"
  #   grader_url       = "https://#{instructor_token}@github.com/#{grader_repo}.git"
  #   expected_repo    = "#{org}/expected-#{project}"
  #   expected_url     = "https://#{instructor_token}@github.com/#{expected_repo}.git"
  #   results_repo     = "#{org}/results-#{project}-#{user}"
  #   results_url      = "https://#{instructor_token}@github.com/#{results_repo}.git"
  #   grade_repo_short = "grade-#{project}-#{user}"
  #   grade_repo       = "#{org}/#{grade_repo_short}"
  #   grade_url        = "https://#{instructor_token}@github.com/#{grade_repo}.git"


  #   Rails.application.config.logger.info type
  #   case type
  #   when 'results'
  #     if not organization.user.github_client.repository?(grade_repo)
  #       organization.user.github_client.create_repository(grade_repo_short, :organization => org, :private => "true")
  #     end
  #     if not organization.user.github_client.collaborator?(grade_repo, user)
  #       #Rails.application.config.logger.info collaborator.login
  #       organization.user.github_client.add_collaborator(grade_repo, user, 'permission' => 'pull')
  #     end
  #     CreateGradeJob.perform_later(results_url,expected_url,grade_url)
  #   when 'expected'
  #   when 'grader'
  #     Rails.application.config.logger.info "Does the repo exist: #{organization.user.github_client.repository?(expected_repo)}"

  #     if not organization.user.github_client.repository?(expected_repo)
  #       organization.user.github_client.create_repository("expected-#{project}", :organization => org, :private => "true")
  #     end
  #     GenerateExpectedJob.perform_later(grader_url,expected_url)
  #   when 'report'
  #   when 'submission'
  #     if not organization.user.github_client.repository?(results_repo)
  #       organization.user.github_client.create_repository("results-#{project}-#{user}", :organization => org, :private => "true")
  #     end
  #     GenerateResultsJob.perform_later(student_url,version,grader_url,results_url)
  #   end
	end

	def github_create(payload)
		# Rails.application.config.logger.info "THERE WAS A CREATE: #{payload}"
	end

	def webhook_secret(payload)
		"topsecret"
    # ENV["WEBHOOK_SECRET"]
	end

	def webhooks
		puts "Went to page!"
	end
end
