class PhpBB

  def initialize(base_url, username, password)
    @base_url = base_url
    @username = username
    @password = password

    @logged_in = false
    @signature = nil

    @agent = Mechanize.new { |agent|
      agent.user_agent = "Arthaey's command-line sig updater; hi! :)"
    }
  end

  def sig_url
    "#{@base_url}/ucp.php?i=ucp_profile&mode=signature"
  end

  def login!
    login_form = @agent.get(sig_url).form_with(:id => "login")
    login_form.username = @username
    login_form.password = @password
    home_page = @agent.submit(login_form, login_form.button_with(:name => "login"))
    if home_page.form_with(:id => "login")
      raise "Could not log in as user #{@username}"
    end
    @logged_in = true
  end

  def signature
    login! if not @logged_in
    if @signature.nil?
      sig_form = @agent.get(sig_url).form_with(:id => "postform")
      @signature = sig_form.signature
    end
    @signature
  end

  def signature=(new_sig)
    login! if not @logged_in

    sig_form = @agent.get(sig_url).form_with(:id => "postform")
    old_sig = signature()

    if old_sig != new_sig
      sig_form.signature = new_sig
      sig_page = @agent.submit(sig_form, sig_form.button_with(:name => "submit"))
      @signature = new_sig
    end

    @signature
  end

end
