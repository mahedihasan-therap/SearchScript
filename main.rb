require 'watir-webdriver'
require 'watir-scroll'
require 'rubygems'
require_relative 'pageAttribute.rb'
require_relative 'login.rb'
require_relative 'Date.rb'
require_relative 'blankCheck.rb'
require_relative 'listPage.rb'
class Main
	def initialize	
		@browser = Watir::Browser.new :chrome
		@context='https://mubin.therapbd.net'
		@login=Login.new(@browser,@context)
		@pageAttribute=PageAttribute.new(@browser,@context)
		@Date=DateData.new
		@blankCheck=BlankCheck.new(@browser,@context)
		@ListPage=ListPage.new(@browser,@context)
		main
    end
    def main
		@browser.goto 'https://mubin.therapbd.net/auth/login'
		provideType=@login.login('jahid','therap','JAHID-SQA')
		sleep 5
		#modulee = gets.chomp
		#modulee='event reports'
		#if provideType=='oversight'
		#	oversightModule(modulee)
		#else
		#	linkClick(modulee)
		#end
		@browser.goto 'https://mubin.therapbd.net/ma/hlth/medReviewSearch?backLink=%2Fnewfpage%2FswitchFirstPage&backType=1'
		
		datalist,processing,textprocessing=@pageAttribute.label
		puts "datalist:#{datalist}"
		flag,datePair,labelSerial=@blankCheck.blankButton(datalist)
		puts "labelSerial:#{labelSerial}"
		if flag==0
			lookUpDataSearch(datePair,datalist)
			sampleData=@ListPage.ListerData
			lookUpDataSet=lookUpData(sampleData,processing,textprocessing)
			@browser.link(text: /New Search/).click
			@blankCheck.report(datalist,lookUpDataSet,labelSerial)
		elsif flag==2
			sampleData=@ListPage.ListerData
			lookUpDataSet=lookUpData(sampleData,processing,textprocessing)
			@browser.link(text: /New Search/).click
			@blankCheck.report(datalist,lookUpDataSet,labelSerial)
 		end
	end
	
	def lookUpData(sampleData,processing,textprocessing)
		lookUpDataSet=Hash.new
		r=sampleData[0]
		keys=textprocessing.keys
		keys.each do |key|
			value=textprocessing[key]
			puts "#{value}"
			if value.include? '('
				helpArr=value.split('(')
				value="#{helpArr[0]}" + "Name"
				if r[value]==nil
					value=textprocessing[key]
				end
			elsif textprocessing[key]=='Individual' && r['Individual']==nil
				value='Individual Name'
				puts "Individual Name"
			else
				value=textprocessing[key]
			end
			if r[value]!=nil
				if r[value].include? ','
					helpArr=r[value].split(',')
					firstvalue=helpArr[0]
					firstvalueSplit=firstvalue.split(' ')
					if firstvalueSplit.length>1
						value=firstvalue
						lookUpDataSet[key]=value
					else
						value="#{helpArr[1].strip}"+" "+"#{helpArr[0].strip}"
						lookUpDataSet[key]=value
					end
				else
					lookUpDataSet[key]=r[value]
				end
			end
		end
		values=processing.values
		len=values.length
		arr=Array.new(len) { |i| Array.new(2) { |i| 0 }}
		j=0
		sampleDataLen=sampleData.length
		while j<sampleDataLen
			row=sampleData[j]
			i=0
			while i<len
				if values[i].include? 'Start Date'
					date=row['From']
				elsif values[i].include? 'End Date'	
					date=row['To']
				elsif values[i].include? 'Valid From'	
					date=row['From']
				elsif values[i].include? 'Valid To'	
					date=row['To']
				elsif values[i].include? 'Submit Date'
					date=row['Date']
				else	
					puts "#{values[i]}:#{row[values[i]]} #{row['Date']}"
					date=row[values[i]]
				end
				puts "date:#{date}"
				if date!=nil
					dateInt=@Date.dateInt(date)
					if (arr[i][0]>dateInt || arr[i][0]==0) && dateInt!=0
							arr[i][0]=dateInt
					end
					if (arr[i][1]<dateInt || arr[i][1]==0) && dateInt!=0
						arr[i][1]=dateInt
					end
				end
				i=i+1
			end
			j=j+1
		end
		i=0
		while i<len
			lookUpDataSet[values[i]]=arr[i]
			i=i+1
		end
		puts "lookUpDataSet: #{lookUpDataSet}"
		return lookUpDataSet
 	end
	def linkClick(modulee)
		@browser.text_field(id: 'dashboardLookup').set modulee
		sleep 5
		myList = @browser.ul(:id => "ui-id-1")
		myArray = []
		myList.lis.each do |li|
		  myArray << li.text
		end
		puts "myArray:#{myArray}"
		myArray.each do |item|
			itemDown=item.downcase
			if itemDown.include? modulee.downcase
				@browser.li(text: item).click
				itemSplit=item.split(':')
				itemString=itemSplit[2]
				@login.wait
				@browser.goto @browser.url
				@login.wait
				@browser.span(text: itemString.strip).parent.parent.link(text: 'Search').click
			end			
		end
	end
	def oversightModule(modulee)
		@browser.h1(text: modulee).parent.li(text: 'Search').click
	end
	def validationCheck(datalist)
		previousUrl=@browser.url
		@browser.button(value: 'Search').click
		afterUrl=@browser.url
		if previousUrl!=afterUrl
			datalist.each do |row|
				if row['required']=='y'
					
				end
			end
		end
	end
	def lookUpDataSearch(datePair,datalist)
		if datePair.empty? || datePair.nil?
			@browser.button(value: 'Search').click
		else
			i=0
			while i<datePair.length
				arr=datePair[i]
				fromDateIndex=arr[0]
				toDateIndex=arr[1]
				puts "before"
				setDatePair(fromDateIndex,toDateIndex,datalist)
				puts "past"
				i=i+1
			end
			puts "#{fromDateIndex.class}"
			
			@browser.button(value: 'Search').click
		end
	end

	def setDatePair(fromDateIndex,toDateIndex,datalist)
	puts "enter"
		fromDataRow=datalist[fromDateIndex]
		fromDateId=fromDataRow['id']
		toDataRow=datalist[toDateIndex]
			toDateId=toDataRow['id']
			labelText=fromDataRow['column']
			datetime_month_before_13_month = DateTime.now << 13
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			datetime_month_previous_13_month = DateTime.now >> 13
			toDate=datetime_month_previous_13_month.strftime("%m/%d/%Y")
			@browser.text_field(id: fromDateId).set fromDate
			@browser.text_field(id: toDateId).set toDate
	end
end
Main.new