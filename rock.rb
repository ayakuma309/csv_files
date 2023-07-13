require 'mechanize'
require 'csv'

agent = Mechanize.new

page = agent.get('https://rijfes.jp/2022/lineup/artists/')
# スクレイピングで取得したデータ

# スクレイピングで取得したデータ
elements = page.search('.c-artist__image img')

data = []
elements.each do |ele|
  data << ele.get_attribute('src')
  sleep 1
end



bom = %w[EF BB BF].map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  data.each do |datum|
    csv << datum
  end
end

File.open('./image.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
