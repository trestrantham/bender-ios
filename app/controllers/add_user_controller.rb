class AddUserController < Formotion::FormController
  attr_accessor :parent_controller
  @parent_controller = nil

  def init
    @form = Formotion::Form.new({
      sections: [{
        title: "New User",
        rows: [{
          title: "Name",
          key: :name,
          placeholder: "First Last",
          type: :string,
          auto_correction: :no
        }, {
          title: "Email",
          key: :email,
          placeholder: "bender@collectiveidea.com",
          type: :email,
          auto_correction: :none
        }]
      }]
    })

    @form.on_submit do
      self.save
    end
    super.initWithForm(@form)
  end

  def viewDidLoad
    super
    self.title = "Create Drinker"

    self.navigationItem.leftBarButtonItem ||= UIBarButtonItem.cancel { cancel }
    self.navigationItem.rightBarButtonItem ||= UIBarButtonItem.save { save }
  end

  def viewDidDisappear(animated)
    super(animated)

    @form.sections.each do |section|
      section.rows.each do |row|
        row.value = ""
      end
    end
  end

  def save
    puts ""
    @form_data = self.form.render
    puts "AddNewUserController > save > @form_data: #{@form_data}"

    user = { user: { name: @form_data[:name], email: @form_data[:email] } } if @form_data.has_key?(:name)

    # Set spinner
    # AppHelper.parse_api(:post, "/users.json", {payload: user}) do |response|
    BW::HTTP.post("#{App::Persistence[:api_url]}/users.json", { payload: user }) do |response|
      if response.ok?
        App.notification_center.post "UserCreatedNotification"
        self.dismissModalViewControllerAnimated(true)
      else
        App.alert("Invalid User")
      end
    end
  end

  def cancel
    self.dismissModalViewControllerAnimated(true)
  end
end
