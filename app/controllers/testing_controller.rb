class TestingController < ApplicationController
  
  require 'sidekiq/api'

  def test
  	Sidekiq::Monitor::Job.where(queue: 'default').destroy_all
  	queue = Sidekiq::Queue.new
  	queue.each do |job|
  		job.delete
  	end

  	# if request.post?
  	# 	TestWorker.perform_async('lol')
  	# end
  end
end
