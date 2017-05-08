require 'watir-webdriver'
class Login
    def initialize (browser,context)
        @browser=browser
        @context=context
    end
    def therapAdm
        login('justin','therap','THERAP-TH')
    end
    def overAdm
        login('therap-adm','therap','DDD-NE')
    end
    def login(usr,pass,prov)
        str,provi=urlPortion
        if str!='auth/login'
            wait
            @browser.link(text: 'Logout').click
            @browser.link(text: /Login Again/).click
        end
        if @browser.link(text: /Try Again/).exists?
            @browser.link(text: /Try Again/).click
        end
        @browser.text_field(:id => "loginName").set usr
        @browser.text_field(:id => "password").set pass
        @browser.text_field(:id => "providerCode").set prov
        @browser.button(:value => "Login").click
        agreeUrl="#{@context}"+"/ma/sa/view"
        splashUrl="#{@context}"+"/ma/splash/view"
		wait
        url=@browser.url
        while url.include? agreeUrl
            @browser.button(value: 'I Agree').click
			wait
			url=@browser.url
        end
        wait
        url=@browser.url
        while url.include? splashUrl
            @browser.div(id: 'btnImg').image(index: 0).click
			wait
			url=@browser.url
        end
		prov=provType
        return prov
    end
    def wait
        begin
            @browser.div(id: 'container').wait_until_present
        rescue e
            puts "Error in waiting:" +e.message
            wait
        end
    end
    def urlPortion
        url=@browser.url
        arr=url.split('/')
        str="#{arr[3]}"+"/"+"#{arr[4]}"
        prov="#{arr[5]}"
        return str,prov
    end
    def logout
        @browser.link(text: 'Logout').click
    end
    def dashboard
        @browser.link(text: 'Dashboard').click        
    end
    def provType
		wait
        str,provType=urlPortion
        if provType=='unifiedDashboard'
            provType='oversight'
        else
            provType='provider'
        end
        provType
    end
end
