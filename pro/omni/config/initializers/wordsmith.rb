Wordsmith.configure do |config|
  config.token = '4b1d5c5ba707ed7f4808f913fff5e5e69dbdbaaccba47a4ca0d37133a60873c5'
  # 4b1d5c5ba707ed7f4808f913fff5e5e69dbdbaaccba47a4ca0d37133a60873c5 #  Wallen
  # 'd8411f2a6843290bc7b511233f9ebcde9f38747a790a47fa541b9df2b70d7f2e' #  Test key(Sam)
  # config.token = "8c7c50a0c2add6af799182f733f1e50b9b2e4f07ce2399fe4bb104371ab96d87" #amit
  #config.token = "3ad54f04bfae9d92d7bf90d5aaa2dedb95e6590a7340ca9e0113d92b71acc62c" #ansuman
  # config.url = 'https://api.automatedinsights.com/v1' #optional, this is the default value
end

##Keeping the texts in array, so as skip some text in PPT slides, app/helper/contents_helper.rb
IGNORE_TEXT = %W(#{"Experiment A"} #{"Experiment B"} #{"Experiment C"} #{"EXPERIMENT A RESULTS"} #{"EXPERIMENT B RESULTS"} #{"EXPERIMENT C RESULTS"})