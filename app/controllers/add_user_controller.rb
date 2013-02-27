class AddUserController < Formotion::FormController
	attr_accessor :parent_controller
  @parent_controller = nil

	def init
		form = Formotion::Form.new({
			sections: [{
				title: "New User",
				rows: [{
					title: "Name",
					key: :name,
					placeholder: "Foo",
					type: :string,
					auto_correction: :no
				}]
			}, {
				rows: [{
					title: "Create",
					type: :submit,
				}]
			}]
		})

		form.on_submit do
			self.save
		end
		super.initWithForm(form)
	end

	def viewDidLoad
		super
		self.title = "Create User"

		self.navigationItem.leftBarButtonItem ||= UIBarButtonItem.alloc.initWithBarButtonSystemItem(
																									UIBarButtonSystemItemCancel, 
																									target:self, 
																									action:"cancel")
	end

	def viewDidDisappear(animated)
		super(animated)

		@table_data = nil
	end

	def save
		puts ""
		@form_data = self.form.render
		puts "AddNewUserController > save > @form_data: #{@form_data}"

		user = {user: {name: @form_data[:name]}} if @form_data.has_key?(:name)

		# Set spinner
		# AppHelper.parse_api(:post, "/users.json", {payload: user}) do |response|
		BW::HTTP.post("#{App::Persistence[:api_url]}/users.json", {payload: user}) do |response|
			if response.ok?
				@parent_controller.load_data if @parent_controller
				self.form.sections[0].rows[0].value = "" # Clear user's name in case modal is called more than once
				self.dismissModalViewControllerAnimated(true)
			else
				App.alert("Invalid User")
			end
		end
	end

	def cancel
		self.form.sections[0].rows[0].value = "" # Clear user's name in case modal is called more than once
		self.dismissModalViewControllerAnimated(true)
	end
end