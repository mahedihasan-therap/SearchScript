require 'watir-webdriver'
require_relative 'login.rb'
require_relative 'listPage.rb'
require_relative 'compare.rb'
require_relative 'Date.rb'
require_relative 'SearchByData.rb'
require_relative 'ReportWrite.rb'
require_relative 'DateCheck.rb'
class BlankCheck
    def initialize (browser,context)
        @browser=browser
        @context=context
		@Compare=Compare.new
		@Date=DateData.new
		@login=Login.new(@browser,@context)
		@ListPage=ListPage.new(@browser,@context)
		@SearchByData=SearchByData.new(@browser,@context)
		@ReportWrite=ReportWrite.new
		@DateCheck=DateCheck.new(@browser,@context)
		@html_file=File.new('report.html','w+')
    end
    def blankButton(datalist)
		welcomeMsg=welcomeTable(datalist)
		previousUrl=@browser.url
		@browser.button(value: 'Search').click
		postUrl=@browser.url
		sampleData=Array.new
		flag=0
		if postUrl.include? 'globalExceptionFeedback'
			puts "App error Occur with below data:"
			flag=1
		elsif @browser.div(class: 'alert alert-danger').exists?
			req=reqCheck(datalist)
			welcomeMsg="#{welcomeMsg}"+'<p style="color:Red"><b>Validation Message :'+"#{@browser.div(class: 'alert alert-danger').text}"+' </p>'
			@ReportWrite.htmlFileCreate(datalist,welcomeMsg,@html_file)
			datePair=createDatePair(datalist)
			message=@DateCheck.datePatternCreate(datePair,datalist)
			@html_file.write("#{message}")
			labelSerial=@ReportWrite.labelTableCreate(datalist,@html_file)
		else
			flag=2
			@ReportWrite.htmlFileCreate(datalist,welcomeMsg,@html_file)
			labelSerial=@ReportWrite.labelTableCreate(datalist,@html_file)
		end
		return flag,datePair,labelSerial
	end
		
	
	def reqCheck(datalist)
		req=0
		datalist.each do |dataRow|
	      if dataRow['labelText'].include? '*'
	      	req=1
	    	end
      	end
      req
  	end
  	def messageCheck(datalist)
  		datalist.each do |dataRow|
  			errSpanId="#{dataRow['id']}"+".errors"
		    if @browser.span(id: errSpanId).exists?
		      	if dataRow['labelText'].include? '*'
		      		puts"okay: #{dataRow['labelText']} #{@browser.span(id: errSpanId).text}"
		      	else
		      		puts"okay: #{dataRow['labelText']} #{@browser.span(id: errSpanId).text}"
		    	end
		    else
		    	if dataRow['labelText'].include? '*'
		      		puts"Wrong: #{dataRow['labelText']} #{dataRow['type']}"
		      	else
		      		puts"okay: #{dataRow['labelText']} #{dataRow['type']}"
		    	end
	      	end
	    end
	end
	def clearData(datalist)
		puts "enter clearData"
		datalist.each do |row|
			if row['type']=='text_field'
				@browser.text_field(id: row['id']).set ''
			elsif row['type']=='dropdown' && row['multiple']=='n'
				ar_vals = @browser.select_list(:id, row['id']).selected_options
				unless ar_vals.empty?
					@browser.select_list(:id, row['id']).select '- Please Select -'
				end
			elsif row['type']=='radio'
				unless @browser.radio(:id, row['id']).clear?
					@browser.radio(:id, row['id']).clear
				end
			end
		end
		puts "close clearData"
	end
	def setData(datalist)
		url=@browser.url
		@browser.goto url
		puts "enter setData" 
		datalist.each do |row|
			if row['required']=='y' && row['max']==0
				@browser.text_field(id: row['id']).set '12/31/2100'
			elsif row['required']=='y' && row['max']==1
				@browser.text_field(id: row['id']).set '01/01/1998'
			end
		end
		puts "close setData"
	end
	def welcomeTable(datalist)
		if @browser.div(class: 'alert alert-warning text-center').exists?
			welcomeMsg='<p style="color:orange"><b>Warning Message :'+"#{@browser.div(class: 'alert alert-warning text-center').text}"+' </p>'
		else
			welcomeMsg=''
		end
		welcomeMsg="#{welcomeMsg}"+'<p style="color:green">
		<b>This is a table of search Page validatin  data: 
		</p>
		<table border="1"style="width:100%"><tr><th> label</th>'
		labelSerial=Array.new
		datalist.each do |datarow|
			label=datarow['labelText']
			welcomeMsg="#{welcomeMsg}"+"<th>"+"#{label}"+"</th>"
			labelSerial << label
		end
		welcomeMsg="#{welcomeMsg}"+"</tr><tr><td>required</td>"
		datalist.each do |datarow|
			if datarow['required']!=nil
				welcomeMsg="#{welcomeMsg}"+"<td>"+"y"+"</td>"
			else
				welcomeMsg="#{welcomeMsg}"+"<td>"+"n"+"</td>"
			end
		end
		welcomeMsg="#{welcomeMsg}"+"</tr><tr><td>Default Value</td>"
		datalist.each do |datarow|
			if datarow['defaultValue']!=nil
				welcomeMsg="#{welcomeMsg}"+"<td>"+"#{datarow['defaultValue']}"+"</td>"
			else
				welcomeMsg="#{welcomeMsg}"+"<td>"+"N\A"+"</td>"
			end
		end
		welcomeMsg="#{welcomeMsg}"+"</tr></table>"
	end
	def report(datalist,lookUpDataSet,labelSerial)
		j=0
		while j<datalist.length
			number=2**j
			pattern="%#{datalist.length}b" % number
			reversePattern=pattern.split("")
			pattern=reversePattern.reverse
			previousUrl=@browser.url
			searchData=@SearchByData.setData(pattern,datalist,lookUpDataSet)
			@browser.button(value: 'Search').click
			sleep 1
			afterUrl=@browser.url
			if afterUrl!=previousUrl
				tableData=@ListPage.ListerData
				msg=@Compare.compare(searchData,tableData)
				@ReportWrite.pushMessage(msg,searchData,labelSerial,@html_file)
				@browser.link(text: /New Search/).click
			else
				if @browser.div(class: 'alert alert-danger').exists?
					validationMsg=@browser.div(class: 'alert alert-danger').text
					@ReportWrite.pushMessage(validationMsg,searchData,labelSerial,@html_file)
				end
				@browser.goto previousUrl
			end
			j=j+1
		end
		@ReportWrite.htmlFileEnd(@html_file)
	end	
	def createDatePair(datalist)
		i=0
		datePair=Array.new
		while i<datalist.length
			arr=Array.new
			dataRow=datalist[i]
			if dataRow['date']=='y'
				arr=Array.new
				arr <<i
				i=i+1
				arr << i
			end
			unless  arr.empty?
				datePair << arr
			end
			i=i+1
		end
		return datePair
	end
	
 end