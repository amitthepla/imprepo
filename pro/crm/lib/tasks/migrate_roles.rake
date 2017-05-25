namespace :crm do
  desc 'Task to migrate role id from roles collection to roles attribute of users collection.'
  task :migrate_roles do
    cnt = 0
    Mongoid::Config.load!('./config/mongoid.yml')
    db = Mongoid::Sessions.default
    collection = db[:users]
    collection.find({}).each do |record|
      if record['role_id'].blank? && record['roles'].present?
        print "Data has been migrated already for _id: #{record['_id']}\n"
        next
      end
      cnt += 1
      print "Updating record ##{cnt}, _id: #{record['_id']}\n"
      # Set +'roles'+ attribute from +'role_id'+ attribute
      collection.find({_id: record['_id']}).update({:$set => {roles: [record['role_id'].to_s].reject(&:blank?)}})
      # Delete +'role_id'+ attribute from collection
      collection.find({_id: record['_id']}).update({:$unset => {role_id: 1}})
    end

    p "total record updated: #{cnt}"
  end
end
