class GithubWebhooksController < ApplicationController
  
	include GithubWebhook::Processor
  # require 'net/ssh'
  # require 'net/ssh/shell'

	# skip_before_filter :verify_authenticity_token, :only => [:index]

	def github_push(payload)
    pushType = payload["repository"]["full_name"].split("/")[1].split("-")[0]
    if pushType == "assignment"
      TestGraderWorker.perform_async(payload)
    end
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
