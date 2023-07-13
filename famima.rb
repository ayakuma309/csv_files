require 'csv'
require 'mechanize'
agent = Mechanize.new
pages = ['https://www.family.co.jp/goods/dessert.html', 'https://www.family.co.jp/goods/wagashi.html']

# スクレイピングで取得したデータを入れる
data = []

pages.each do |pg|
  page = agent.get(pg)
  elements = page.search('.ly-mod-infoset4 a')

  # 詳細ページのURLリスト
  urls = []

  # aタグの中のURLを引き抜く
  elements.each do |ele|
    urls << ele.get_attribute(:href)
  end

  # それぞれの詳細ページにアクセスする
  urls.each_with_index do |url, i|
    page = agent.get(url)
    p "name: #{page.at('.ly-mod-ttl-main').inner_text}"
    data << [
      name = page.at('.ly-mod-ttl-main').inner_text,
      # price = page.at('.ly-kakaku-usual span').inner_text.match(/[^円]+/).to_s.to_f.round,
      description = page.at('.ly-goods-lead').inner_text,
      image = "https://www.family.co.jp" + page.at('.js-mainimage-size img').get_attribute('src'),
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

File.open('./famima.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
