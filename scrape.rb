require 'mechanize'
require 'csv'

agent = Mechanize.new

page = agent.get('https://www.asahiinryo.co.jp/products/carbonated/')
# スクレイピングで取得したデータ
data = []

elements = page.search('.product-list li a')

# 詳細ページのURLリスト
urls = []

# aタグの中のURLを引き抜く
elements.each do |ele|
  urls << ele.get_attribute(:href).gsub(/\.\.carbonated\//, "")
end

# それぞれの詳細ページにアクセスする
urls.each_with_index do |url, i|
  page = agent.get('https://www.asahiinryo.co.jp/products/carbonated/'+url)
  p "name: #{page.at('.product-name').inner_text}"
  p "image: #{page.at('.product-image img').get_attribute('src')}"
  data << [
    name = page.at('.product-name').inner_text,
    image = "	https://www.asahiinryo.co.jp" + page.at('.product-image img').get_attribute('src'),
  ]
  sleep 1
end


bom = %w[EF BB BF].map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  data.each do |datum|
    csv << datum
  end
end

File.open('./item3-product.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
