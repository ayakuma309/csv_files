require 'csv'
require 'mechanize'
agent = Mechanize.new
pages = ["https://www.sej.co.jp/products/a/cat/060020010000000/1/l15/","https://www.sej.co.jp/products/a/cat/060020010000000/2/l15/","https://www.sej.co.jp/products/a/cat/060020010000000/6/l15/", "https://www.sej.co.jp/products/a/cat/060020010000000/7/l15/"]

# スクレイピングで取得したデータ
data = []

pages.each do |pg|
  page = agent.get(pg)
  elements = page.search('.list_inner figure a')

  # 詳細ページのURLリスト
  urls = []

  # aタグの中のURLを引き抜く
  elements.each do |ele|
    urls << ele.get_attribute(:href)
  end

  # それぞれの詳細ページにアクセスする
  urls.each_with_index do |url, i|
    page = agent.get(url)
    p "name: #{page.at('.item_ttl h1').inner_text}"
    data << [
      name = page.at('.item_ttl h1').inner_text,
      image = page.at('.productWrap ul li img').get_attribute('src')
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

File.open('./ice-product.csv', 'w', force_quotes: true) do |file|
  file.write(csv_file.force_encoding('UTF-8'))
end
