require 'date'
class DateData
	def nextDate(previousDate)
		currentDate=previousDate+1
		response=dateCheck(currentDate)
		if response!='true'
			year,month,date=dateSplit(currentDate)
			if month<12
				month=month+1
				date='01'
				if month<10
					month="0"+"#{month}"
				end
			else
				year=year+1
				month='01'
				date='01'
			end
			currentDateString="#{year}"+"#{month}"+"#{date}"
			currentDate=currentDateString.to_i
		end
		return currentDate
	end
	
	def dateCheck(date)
		response=""
		year,month,date=dateSplit(date)
		if year%4==0
			if month<=12
				if month==1 || month==3 || month==5 || month==7 || month==8 || month==10 || month==12
					if date<32
						response="true"
					end
				elsif month==4 || month==6 || month==9 || month==11
					if date<31
						response="true"
					end
				elsif month==2
					if date<30
						response="true"
					end
				end
			end
		else
			if month<=12
				if month==1 || month==3 || month==5 || month==7 || month==8 || month==10 || month==12
					if date<32
						response="true"
					end
				elsif month==4 || month==6 || month==9 || month==11
					if date<31
						response="true"
					end
				elsif month==2
					if date<29
						response="true"
					end
				end
			end
		end
		return response
	end
	
	def dateSplit(date)
		dateString="#{date}"
		dateArray=dateString.split('')
		yearString="#{dateArray[0]}"+"#{dateArray[1]}"+"#{dateArray[2]}"+"#{dateArray[3]}"
		year=yearString.to_i
		monthString="#{dateArray[4]}"+"#{dateArray[5]}"
		month=monthString.to_i
		dateString="#{dateArray[6]}"+"#{dateArray[7]}"
		date=dateString.to_i
		return year,month,date
	end
	def datePattern(date)
		year,month,date=dateSplit(date)
		if month<10
				month="0"+"#{month}"
		end
		if date<10
			date="0"+"#{date}"
		end
		date="#{month}"+"/"+"#{date}"+"/"+"#{year}"
	end
	def dateInt(date)
		dateSplit=date.split('/')
		date=dateSplit[1]
		month=dateSplit[0]
		year=dateSplit[2]
		dateString="#{year}"+"#{month}"+"#{date}"
		dateInt=dateString.to_i
		return dateInt
	end
	def getCurrentDate
		time=Time.new
		time=time.strftime("%m/%d/%y")
		return time
	end
end
