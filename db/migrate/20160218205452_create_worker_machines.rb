class CreateWorkerMachines < ActiveRecord::Migration
  def change
    create_table :worker_machines do |t|

      t.timestamps null: false
    end
  end
end
