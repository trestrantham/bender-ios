class PourHandler
  def setup
    @current_pours = {}
    @current_users = {}
  end

  def pour_update(pour, current_user_id)
    puts ""
    puts "PourHandler > pour_update"

    # We can't do anything without a pour id
    return unless pour.has_key?(:id)

    # Send an update for this pour if the current user doesn't match the pour's user_id
    update_pour_user(pour[:id], current_user_id) if pour.fetch(:user_id, 0).to_i != current_user_id

    @current_pours[pour[:id]] = Time.now

    EM.add_timer App::Persistence[:pour_timeout].to_i do
      if @current_pours.has_key?(pour[:id]) && @current_pours[pour[:id]] + App::Persistence[:pour_timeout].to_i <= Time.now
        puts "PourHandler > pour_update > POUR TIMED OUT"
        App.notification_center.post "PourTimeoutNotification"

        @current_pours.delete(pour[:id])
      end
    end
  end

  # Set the current user as active for the user_timeout period.
  # Calling this repeatedly (as done during a pour event) will keep the user 'alive'.
  def user_update(user)
    puts ""
    puts "PourHandler > user_update"

    # We can't do anything without a user id
    return unless user.has_key?(:id)

    @current_users[user[:id]] = Time.now

    EM.add_timer App::Persistence[:user_timeout].to_i do
      if @current_users.has_key?(user[:id]) && @current_users[user[:id]] + App::Persistence[:user_timeout].to_i <= Time.now
        puts "PourHandler > user_update > USER TIMED OUT #{user}"
        App.notification_center.post("UserTimeoutNotification", nil, user)

        @current_users.delete(user[:id])
      end
    end
  end

  def update_pour_user(pour_id, user_id)
    puts ""
    puts "PourHandler > update_pour_user"

    # Don't see guest updates
    return unless user_id.to_i > 0

    pour_user = { pour: { user_id: user_id } }

    AppHelper.parse_api(:put, "/pours/#{pour_id}.json", { payload: pour_user }) do |response|
      puts "PourHandler > update_pour_user > PUT finished: /pours/#{pour_id}.json user_id: #{user_id}"
      App.notification_center.post "PourUserUpdatedNotification"
    end
  end
end
