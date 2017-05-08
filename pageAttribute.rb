require 'watir-webdriver'
class PageAttribute
    def initialize (browser,context)
        @browser=browser
        @context=context
		@login=Login.new(@browser,@context)
    end
    def label
    	@datalist=[]
		i=0
		autoComTrack=1
		flag=0
		while i<100 && flag==0
			if @browser.label(index: i).exists? 
				labelFor="#{@browser.label(index: i).for}"
				if labelFor.strip!='' 
					labelSplit="#{@browser.label(index: i).parent.text}".split("\n")
					labelText=labelSplit[0]
					dataRow= Hash.new
					if labelText!=nil
						elm="#{@browser.label(index: i).for}"
						type=idType(elm)
						dataRow['id']="#{labelFor.strip}"
						dataRow['type']="#{type}"
						dataRow['labelText']="#{labelText}"
						if dataRow['labelText'].include? '*'
							labelText=dataRow['labelText']
							label=labelText.sub('*  ','')
							dataRow['labelText']="#{label}"
							dataRow['required']='y'
						end
						if type=='dropdown'
							arr,multiple=inputData(elm)
							dataRow['options']=arr
							dataRow['multiple']=multiple
						#elsif type=='radio'
						#	dataRow['options']=radioValue(elm)
						elsif type=='text_field'
							place_holder=@browser.text_field(id: dataRow['id']).placeholder
							inner_html=@browser.text_field(id: dataRow['id']).html
							if place_holder=='MM/DD/YYYY'
								dataRow['date']='y'
							end
							if inner_html.include? 'autocomplete'
								dataRow['autoComTrack']=autoComTrack
								dataRow['autocomplete']='y'
								autoComTrack=autoComTrack+1
							end
							defaultValue=@browser.text_field(id: dataRow['id']).value
							if defaultValue.nil?  || defaultValue!=''
								dataRow['defaultValue']="#{defaultValue}"
							end
						end
					@datalist << dataRow
					end
				end
			else 
				flag=1
			end
			i=i+1
		end
		processing=dateProcess
		textprocessing=Hash.new
		requiredColumn=Array.new
		@datalist.each do |row|
			if (row['autocomplete']=='y')
				textprocessing[row['id']]="#{row['labelText']}"
			elsif row['labelText'].include? 'Form ID'
				textprocessing[row['id']]="#{row['labelText']}"
			elsif row['labelText'].include? 'Oversight ID'
				textprocessing[row['id']]="#{row['labelText']}"
			end
			
		end
		return @datalist,processing,textprocessing
	end
	def radioValue(elm)
		i=0
		value=Array.new
		while @browser.radio(id: elm).parent.radio(index: i).exists?
			value << @browser.radio(id: elm).parent.radio(index: i).value
			i=i+1
		end
		return value
	end
	def idType(id)
		if @browser.text_field(id: id).exists?
			type='text_field'
		elsif @browser.select_list(id: id).exists?
			tag_name="#{@browser.element(id: id).tag_name}"
			if tag_name=='select'
				type='dropdown'
			elsif tag_name=='input'
				type='radio'
			end
		elsif @browser.radio(id: id).exists?
			type='radio'
		elsif @browser.checkbox(id: id).exists?
			type='checkbox'
		elsif @browser.button(id: id).exists?
			type='button'
		end
		type
	end
	def inputData(elm)
		if @browser.select_list(id: elm).multiple?
			arr=@browser.select_list(id: elm).options.map(&:text)
			multiple='y'
		else
			arr=@browser.select_list(id: elm).options.map(&:text)
			arr.shift
			multiple='n'
		end
		return arr,multiple
	end	
	def dateProcess
		processing=Hash.new
		@datalist.each do |row|
			if row['date']=='y'
				id=row['id']
				id1=id.chomp('From')
				id2=id1.chomp('To')
				if id.gsub(id2,'')=='From'
					puts 'enter'
					column=row['labelText'].chomp(' From')
					processing[id2]="#{column}"
				end
			end
		end
		i=0
		deletingIndex=Array.new
		while i<@datalist.length
			row=@datalist[i]
			if row['date']=='y'
				id=row['id']
				id1=id.chomp('From')
				id2=id1.chomp('To')
				row['column']=processing[id2]
				if id.gsub(id2,'')=='From'
					row['max']=1
				elsif id.gsub(id2,'')=='To'
					row['max']=0
				end
			end
			if row['labelText']==""
				deletingIndex << i
			end
			i=i+1
		end	
		unless deletingIndex.empty?
			i=0
			while i< deletingIndex.length
				@datalist.delete(deletingIndex(i))
				i=i+1
			end
		end
		return processing
	end
end

