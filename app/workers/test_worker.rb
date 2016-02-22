class TestWorker

	include Sidekiq::Worker

	def perform(test)
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"

		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"

		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"
		puts "fdsafadsfsadfsdafasfsdfs"

	end

	def self.job_name(test)
		"Test Job"
	end
end