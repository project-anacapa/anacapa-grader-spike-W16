class TestingController < ApplicationController
  
  def test
  	Sidekiq::Monitor::Job.where(queue: 'default').destroy_all

  	# if request.post?
  	# 	TestWorker.perform_async('lol')
  	# end
  end
end
