require 'csv'
require 'mechanize'
agent = Mechanize.new
pages = ['https://www.lawson.co.jp/recommend/original/dessert/', 'https://www.lawson.co.jp/recommend/original/gateau/index.html']

# スクレイピングで取得したデータ
data = []

pages.each do |pg|
  page = agent.get(pg)
  elements = page.search('.heightLineParent li p a')

  # 詳細ページのURLリスト
  urls = []

  # aタグの中のURLを引き抜く
  elements.each do |ele|
    urls << ele.get_attribute(:href)
  end

  # それぞれの詳細ページにアクセスする
  urls.each_with_index do |url, i|
    page = agent.get(url)
    p "name: #{page.at('.rightBlock p').inner_text}"
    data << [
      name = page.at('.rightBlock p').inner_text,
      calories = page.at('.rightBlock dl dd').inner_text.match(/[^kcal]+/).to_s.to_f.round,
      description = page.at('.rightBlock .text').inner_text,
      image = "https://www.lawson.co.jp" + page.at('.leftBlock p img').get_attribute('src'),
    ]
    sleep 1
  end
end

bom = %w[EF BB BF].map { |e| e.hex.chr }.join
csv_file = CSV.generate(bom) do |csv|
  data.each do |datum|
    csv << datum
  end
end

File.open('./loson.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
