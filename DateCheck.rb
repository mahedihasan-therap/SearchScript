class DateCheck
	def initialize (browser,context)
        @browser=browser
        @context=context
	end
	def datePatternCreate(datePair,datalist)
		message=''
		puts "datePair:#{datePair}"
		unless datePair.nil?
			datePair.each do |arr|
			puts "arr: #{arr}"
				fromDateIndex=arr[0]
				toDateIndex=arr[1]
				puts "#{fromDateIndex.class}"
				fromDataRow=datalist[fromDateIndex]
				fromDateId=fromDataRow['id']
				toDataRow=datalist[toDateIndex]
				toDateId=toDataRow['id']
				labelText=fromDataRow['column']
				previousUrl=@browser.url
				i=1
				message="#{message}"+'<p style="color:gold"><b>'+"#{labelText}"+'</p><table border="1"style="width:100%"><tr><th>From Date</th><th>To Date</th><th>Messege</th></tr>'
				while i<9
					fromDate,toDate=submitDate(i,fromDateId,toDateId)
					@browser.button(value: 'Search').click
					sleep 1
					afterUrl=@browser.url
					message="#{message}"+'<tr><td>'+"#{fromDate}"+'</td><td>'+"#{toDate}"+'</td>'
					if afterUrl!=previousUrl
						message="#{message}"+"<td>getresult</td></tr>"
						puts "break"
						@browser.link(text: /New Search/).click
						puts "pass"
					else
						if @browser.div(class: 'alert alert-danger').exists?
							validationMsg=@browser.div(class: 'alert alert-danger').text
							message="#{message}"+"<td>#{validationMsg}</td></tr>"
						end
						@browser.goto previousUrl
					end
					i=i+1
				end
				message="#{message}"+"</table>"
			end
		end
		return message
	end
	def submitDate(i,fromDateId,toDateId)
		currentDate=Time.now.strftime("%m/%d/%Y")
		if i==1
			fromDate='11/11/1998'
			toDate=''
			withFromDate(fromDateId,'11/11/1998',toDateId,'')
		elsif i==2
			datetime_month_before_13_month = DateTime.now << 14
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=''
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==3
			datetime_month_before_13_month = DateTime.now << 12
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=''
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==4
			datetime_month_before_13_month = DateTime.now << 12
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=currentDate
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==5
			datetime_month_before_13_month = DateTime.now << 6
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=''
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==6
			datetime_month_before_13_month = DateTime.now << 6
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=currentDate
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==7
			datetime_month_before_13_month = DateTime.now << 3
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			toDate=currentDate
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		elsif i==8
			datetime_month_before_13_month = DateTime.now << 3
			fromDate=datetime_month_before_13_month.strftime("%m/%d/%Y")
			datetime_month_previous_13_month = DateTime.now >> 3
			toDate=datetime_month_previous_13_month.strftime("%m/%d/%Y")
			withFromDate(fromDateId,fromDate,toDateId,toDate)
		end
		return fromDate,toDate
	end
	def withFromDate(fromDateId,fromDate,toDateId,toDate)
		@browser.text_field(id: fromDateId).set fromDate
		@browser.text_field(id: toDateId).set toDate
	end
end
