require 'watir-webdriver'
require_relative 'Date.rb'
class Compare
	def initialize 
		@Date=DateData.new
    end
    def compare(searchData,tableData)
		msg=''
		unless searchData.empty?
			keys=searchData.keys
			unless tableData.empty?
				i=1
				tableData.each do |tableRow|
					keys.each do |key| 
						searchVal=searchData[key]
						if key.include? 'Start Date'
							searchTableVal=tableRow['From']
						elsif key.include? 'End Date'	
							searchTableVal=tableRow['To']
						elsif key.include? 'Valid From'	
							searchTableVal=tableRow['From']
						elsif key.include? 'Valid To'
							searchTableVal=tableRow['To']
						elsif key=='Submit Date' && tableRow['Submit Date']==nil
							searchTableVal=tableRow['Date']
						elsif key=='Status' && tableRow['Status']==nil
							searchTableVal=tableRow['Acknowledgement Status']
						elsif key=='Notification Level' && tableRow['Notification Level']==nil
							searchTableVal=tableRow['NL']
						elsif key=='Program Name' && tableRow['Program Name']==nil
							searchTableVal=tableRow['Program (Site)']
						elsif key=='Individual' && tableRow['Individual']==nil
							searchTableVal=tableRow['Individual Name']
						else	
							searchTableVal=tableRow[key]
						end
						puts "key:#{key}  searchTableVal: #{searchTableVal} -- searchVal: #{searchVal}"
						searchValClass="#{searchVal.class}"
						if searchValClass == 'Array'
							unless  searchVal.include? searchTableVal
							end
						elsif ( key.include? "Date") || ( key.include? "From") || ( key.include? "To")
							unless searchTableVal.nil?
								searchTableDateFormatting=@Date.dateInt(searchTableVal)
								min=searchVal['min']
								max=searchVal['max']
								if 	max==0 && min!=0
										unless (min<=searchTableDateFormatting )
											msg= "not match in line:"
											puts "#{min}  #{searchTableDateFormatting}"
										end
								elsif min==0 && max!=0
										unless  (max>=searchTableDateFormatting )
											msg= "not match in line:"
											puts "#{max}  #{searchTableDateFormatting}"
										end
								else	
									puts "min--#{min.class}  searchTableDateFormatting:#{searchTableDateFormatting}"
									unless (min<=searchTableDateFormatting )&& (max>=searchTableDateFormatting )
										msg= "not match in line:"
									end	
								end
							end
						else
							unless searchVal==searchTableVal
								msg= "not match in line:"
							end
						end
					end
					unless msg==''
					puts "#{msg}"
						msg="#{msg}"+"#{i},"
					end
					i=i+1
				end
			end
		end
		return msg
	end
end