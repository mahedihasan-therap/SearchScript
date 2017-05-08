require 'watir-webdriver'
class ListPage
    def initialize (browser,context)
        @browser=browser
        @context=context
    end
	def ListerData
		if @browser.div(text: 'Nothing found to display').exists?
			tableData=[]
		else
			serial=getSerial
			tableData=tableHandle(serial)
			i=2
			while @browser.link(text: "#{i}").exists?
				@browser.link(text: "#{i}").click
				linkSerial=getSerial
				tablelinkData=tableHandle(linkSerial)
				tableData=tableData+tablelinkData
				i=i+1
			end
		end
		return tableData
	end
	def getSerial
		table = @browser.table(id: 'dataList')
		tableCommon_array = Array.new
		table.rows.each do |row|
			rowCommon_array = Array.new
			row.cells.each do |cell|
				rowCommon_array << cell.text
			end
			tableCommon_array << rowCommon_array
		end
		return tableCommon_array[0]
	end
	def tableHandle(serial)
		table_array = Array.new
		tableCommon_array = Array.new
		table = @browser.table(id: 'dataList')
		table.rows.each do |row|
			row_hash = Hash.new
			i=0
			row.cells.each do |cell|
				key=serial[i]
				if key!=''
					if cell.text.include? '/'
						cellTextSplit=cell.text.split('/')
						if cellTextSplit.length==3
							cellText=cell.text.strip
						else
							cellText=cellTextSplit[0].strip
						end
					else
						cellText=cell.text.strip
					end
					if cellText.include? ','
						helpArr=cellText.split(',')
						firstvalue=helpArr[0]
						firstvalueSplit=firstvalue.split(' ')
						if firstvalueSplit.length>1
							value=firstvalue
							row_hash[key]=value.strip
						else
							value="#{helpArr[1].strip}"+" "+"#{helpArr[0].strip}"
							row_hash[key]=value.strip
						end
					else
					row_hash[key] = cellText.strip
					end
				end
				i=i+1
			end
			table_array << row_hash
		end
		if @browser.table(index: 0).attribute_value("class")=='table'
			table_array=commonTableHandle(table_array)
		end
		table_array.shift
		return table_array
	end
	def commonTableHandle(table_array)
		tableCommon_array = Array.new
		table = @browser.table(index: 0)
		table.rows.each do |row|
			rowCommon_array = Array.new
				row.cells.each do |cell|
					if cell.text.include? '/'  
						cellTextSplit=cell.text.split('/')
						if cellTextSplit.length==3
							cellText=cell.text.strip
						else
							cellText=cellTextSplit[0].strip
						end
					else
						cellText=cell.text.strip
					end
					if cellText.include? ','
						helpArr=cellText.split(',')
						value="#{helpArr[1].strip}"+" "+"#{helpArr[0].strip}"
						rowCommon_array << value
					else
						rowCommon_array << cellText
					end
			end
			tableCommon_array << rowCommon_array
		end
		table_array.each do |dataRow|
			tableCommon_array.each do |row|
				key=row[0]
				value=row[1]
				dataRow[key]=value
			end
		end
		return table_array
	end
end