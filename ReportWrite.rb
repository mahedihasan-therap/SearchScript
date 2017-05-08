require_relative 'Date.rb'
class ReportWrite
	def initialize
		@Date=DateData.new
	end
	def htmlFileCreate(datalist,welcomeMsg,html_file)
		html_file.write('<!DOCTYPE html>
		<html>
		<body>')
		html_file.write("#{welcomeMsg}")
		
	end
	def labelTableCreate(datalist,html_file)
		html_file.write('
		<p style="color:blue">
		<b>This is a table of showing data: 
		</p>
		<table border="1"style="width:100%"><tr>')
		labelSerial=Array.new
		datalist.each do |datarow|
			label=datarow['labelText']
			html_file.write("<th>#{label}</th>")
			labelSerial << label
		end
		html_file.write("<th> </th></tr>")
		return labelSerial
	end
	def pushMessage(msg,searchData,labelSerial,html_file)
		i=0
		html_file.write("<tr>")
		while i<labelSerial.length
			if labelSerial[i].include? 'From'
				newlabelSerial=labelSerial[i]
				newlabelSerialWithoutFrom=newlabelSerial.sub(' From','')
				dataHash=searchData[newlabelSerialWithoutFrom]
				if dataHash.nil?
					html_file.write("<td></td><td></td>")
					i=i+2
				else
					puts "dataHash: #{dataHash}"
					if dataHash['min']!=0 && dataHash['max']==0
						min=dataHash['min']
						fromDate=@Date.datePattern(min)
						puts "min"
						html_file.write("<td>#{fromDate}</td><td></td>")					
					elsif dataHash['max']!=0 && dataHash['min']==0
						toDate=@Date.datePattern(dataHash['max'])
						html_file.write("<td></td><td>#{toDate}</td>")
						puts "max"
					elsif dataHash['min']!=0 && dataHash['max']!=0
						fromDate=@Date.datePattern(dataHash['min'])
						toDate=@Date.datePattern(dataHash['max'])
						html_file.write("<td>#{fromDate}</td><td>#{toDate}</td>")
						puts "minmax"
					end
					i=i+2
				end
			else
				label=labelSerial[i]
				data=searchData[label]
				if label.include? '('
					helpArr=label.split('(')
					label="#{helpArr[0]}" + "Name"
					data=searchData[label]
				else
					data=searchData[label]
				end
				dataClass="#{data.class}"
				if dataClass=='Array'
					s=data.join(",")
					html_file.write("<td>#{s}</td>")
				else
					html_file.write("<td>#{data}</td>")
				end
				i=i+1
			end
		end
		html_file.write("<td>#{msg}</td></tr>")
	end
	
	def htmlFileEnd(html_file)
		html_file.write("</table>

	</body>
	</html>")
	end
end
