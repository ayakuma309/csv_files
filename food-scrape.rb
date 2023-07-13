require 'mechanize'
require 'csv'

agent = Mechanize.new

page = agent.get('https://www.meiji.co.jp/products/chocolate/')
# スクレイピングで取得したデータ
data = []

images = page.search('.l-card-frame img')
names = page.search('.m-txtLink-block')

data <<  images.map{|image| "https://www.meiji.co.jp" + image.get_attribute('src')}
data += names.map{|t| t.children[0].inner_text}.each_slice(5).to_a


p "name: #{page.at('.m-txtLink-block').inner_text}"
p "image: #{page.at('.l-card-frame img').get_attribute('src')}"
# data << [
#   name = page.at('.l-card-body p').inner_text,
#   image = "https://www.meiji.co.jp" + page.at('.l-card-frame img').get_attribute('src'),
# ]
# sleep 1



bom = %w[EF BB BF].map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  data.each do |datum|
    csv << datum
  end
end

File.open('./food-product.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
