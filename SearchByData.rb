require 'watir-webdriver'
require_relative 'login.rb'
require_relative 'listPage.rb'
require_relative 'compare.rb'
require_relative 'Date.rb'
class SearchByData
	def initialize (browser,context)
        @browser=browser
        @context=context
		@Compare=Compare.new
		@Date=DateData.new
		@login=Login.new(@browser,@context)
		@ListPage=ListPage.new(@browser,@context)
    end
	def setData(pattern,datalist,lookUpDataSet)
		j=0	
		searchData=Hash.new
		puts "pattern:#{pattern}"
		while j<pattern.length
			if pattern[j]=='1'
				# indexing=index[j]
				# puts "indexing:#{indexing}"
				# indexClass="#{indexing.class}"
				# if indexClass=='Array'
					# indexNum=indexing[0]
					# datarow=datalist[indexNum]
					# id=datarow['id']
					# indexOption=indexing[1]
					# option=datarow['options']
					# label=datarow['labelText']
					# value=option[indexOption]
					# if searchData[label].nil?
						# arr=Array.new
						# arr << value
						# searchData[label] = arr
					# else
						# arr=searchData[label]
						# arr << value
						# searchData[label] = arr
					# end
					# @browser.select_list(id: id).select value
				# else
					datarow=datalist[j]
					puts "datarow:#{datarow}"
					id=datarow['id']
					type=datarow['type']
					label=datarow['labelText']
					if type=='text_field'
						if (id=='clientLookup' || id=='mappedClientLookup' ) ||  datarow['autocomplete']=='y'
							setIndividualData(lookUpDataSet[id],id,datarow['autoComTrack'])
							if label.include? '('
								helpArr=label.split('(')
								label="#{helpArr[0]}" + "Name"
								searchData[label]="#{lookUpDataSet[id]}"
							else
								searchData[label]="#{lookUpDataSet[id]}"
							end
						elsif id.include? 'ormId'
							@browser.text_field(id: id).set lookUpDataSet[id]
							searchData[label]="#{lookUpDataSet[id]}"
						elsif id.include? 'oversightId'
							@browser.text_field(id: id).set lookUpDataSet[id]
							searchData[label]="#{lookUpDataSet[id]}"
						elsif datarow['date']=='y'
							if datarow['max']==1
								minMaxArr=lookUpDataSet[datarow['column']]
								dateArr=Hash.new
								dateArr['min']=minMaxArr[0]
								dateArr['max']=0
								searchData[datarow['column']]=dateArr
								if minMaxArr[0]!=0
									dateFormatting=@Date.datePattern(minMaxArr[0])
									@browser.text_field(id: id).set dateFormatting
								end
							elsif datarow['max']==0
								minMaxArr=lookUpDataSet[datarow['column']]
								if searchData[datarow['column']].nil?
									dateArr=Hash.new
									dateArr['min']=0
									dateArr['max']=minMaxArr[1]
									searchData[datarow['column']] = dateArr
								else
									dateArr=searchData[datarow['column']]
									dateArr['max'] =minMaxArr[1]
									searchData[datarow['column']] = dateArr
								end
								searchData[datarow['column']]=dateArr
								if minMaxArr[1]!=0
									dateFormatting=@Date.datePattern(minMaxArr[1])
									@browser.text_field(id: id).set dateFormatting
								end
							end
						else
							@browser.text_field(id: id).set 'moskora'
							searchData[label]='moskora'
						end
					elsif type=='checkbox'
						@browser.checkbox(id: id).set
						searchData[label]="#{id}"
					elsif type=='dropdown'
						puts "id : #{id}"
						option=datarow['options']
						value=option[1]
						searchData[label]="#{value}"
						@browser.select_list(id: id).select value
					end
				#end
			end
			j=j+1
		end
		return searchData
	end
	def setIndividualData(name,id,autoComTrack)
		@browser.text_field(id: id).set name
		flag=0
		i=0
		while flag==0
			ulId="ui-id-"+"#{autoComTrack}"
			if @browser.ul(:id => ulId).exists?
				myList = @browser.ul(:id => ulId)
				myArray = []
				myList.lis.each do |li|
					myArray << li.text
				end
				myArray.each do |item|
					itemDown=item.downcase
					if itemDown.include? name.downcase
						@browser.li(text: item).click
						flag=1
					end			
				end
			end
		end
	end
end