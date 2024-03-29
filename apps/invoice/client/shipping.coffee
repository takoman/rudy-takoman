_ = require 'underscore'
Q = require 'q'
Backbone = require 'backbone'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
Order = require '../../../models/order.coffee'
OrderLineItem = require '../../../models/order_line_item.coffee'
Product = require '../../../models/product.coffee'
CheckoutHeaderView = require '../../../components/checkout_header/view.coffee'
acct = require 'accounting'
template = -> require('../templates/shipping.jade') arguments...
{ SESSION_ID } = require('sharify').data

module.exports = class ShippingView extends Backbone.View
  events:
    'submit .form-contact-and-shipping': 'submitContactAndShipping'

  initialize: (options) ->
    { @merchant, @invoice, @invoiceLineItems } = options
    @order = new Order @invoice.get('order')
    @customer = @order.related().customer
    @render()
    @initializeAddressWidget()
    @prepopulate()

  render: ->
    @$el.html template
      countries: @getCountriesList()
      _: _
      acct: acct
      merchant: @merchant
      invoice: @invoice
      invoiceLineItems: @invoiceLineItems

    @renderInvoiceLineItems()

  prepopulate: ->
    # Have to select city and trigger change first for the twzipcode to
    # populate the dropdown options of district. Then we can select it.
    @$('[name="city"]').val(@order.get('shipping_address')?['city']).trigger 'change'
    _.each @order.get('shipping_address'), (v, k) => @$("[name='#{k}']").val v

    unless @customer.isNew()
      Q(@customer.fetch())
        .then => _.each @customer.attributes, (v, k) => @$("input[name='#{k}']").val v
        .catch -> console.log 'fetch customer failed'
        .done()

  # Create/save the customer and update the order with the shipping address
  # and the customer.
  submitContactAndShipping: (e) ->
    e.preventDefault()
    @order.set
      shipping_address:
        address: @$('input[name="address"]').val()
        district: @$('select[name="district"]').val()
        city: @$('select[name="city"]').val()
        zipcode: @$('input[name="zipcode"]').val()
        country: @$('select[name="country"]').val()

    @customer.set
      name: @$('input[name="name"]').val()
      email: @$('input[name="email"]').val()
      phone: @$('input[name="phone"]').val()
      anonymous: true
      anonymous_session_id: SESSION_ID

    Q(@customer.save())
      .then => Q @order.set(customer: @customer.get('_id')).save()
      .then => Backbone.history.navigate "/invoices/#{@invoice.get('_id')}/payment?access_key=#{@invoice.get('access_key')}", trigger: true
      .catch (error) -> console.log error
      .done()

  renderInvoiceLineItems: ->
    @invoiceLineItems.each (invoiceLineItem) ->
      oli = invoiceLineItem.get('order_line_item')
      product = new Product(_id: oli.product) if oli.product?
      Q(product?.fetch())  # When the item is not a product, this will be undefined.
        .then ->
          $ili = $("[data-invoice-line-item-id='#{invoiceLineItem.get('_id')}']")
          $ili.find('.invoice-line-item-image').html "<img src='#{product.get('images')?[0]?.original}'>"
          $ili.find('.invoice-line-item-brand').text "#{product.get('brand')}"
          $ili.find('.invoice-line-item-title').text "#{product.get('title')}"
        .catch -> undefined
        .done()

  initializeAddressWidget: ->
    @$('form').twzipcode()

  # TODO: move this to a model or a helper
  getCountriesList: ->
    countries =
      "AD": "安道爾"
      "AE": "阿拉伯聯合大公國"
      "AF": "阿富汗"
      "AG": "安地卡及巴布達"
      "AI": "安圭拉"
      "AL": "阿爾巴尼亞"
      "AM": "亞美尼亞"
      "AO": "安哥拉"
      "AQ": "南極大陸"
      "AR": "阿根廷"
      "AS": "美屬薩摩亞"
      "AT": "奧地利"
      "AU": "澳大利亞"
      "AW": "阿路巴"
      "AZ": "亞塞拜然"
      "BA": "波士尼亞與赫塞哥維納"
      "BB": "巴貝多"
      "BD": "孟加拉"
      "BE": "比利時"
      "BF": "布吉納法索"
      "BG": "保加利亞"
      "BH": "巴林"
      "BI": "蒲隆地"
      "BJ": "貝南"
      "BL": "法屬聖巴泰勒米島"
      "BM": "百慕達"
      "BN": "汶萊"
      "BO": "玻利維亞"
      "BR": "巴西"
      "BS": "巴哈馬"
      "BT": "不丹"
      "BV": "布威島"
      "BW": "波札那"
      "BY": "白俄羅斯"
      "BZ": "貝里斯"
      "CA": "加拿大"
      "CC": "可可斯群島"
      "CD": "剛果民主共和國"
      "CF": "中非共和國"
      "CG": "剛果民主共和國"
      "CH": "瑞士"
      "CI": "象牙海岸"
      "CK": "柯克群島"
      "CL": "智利"
      "CM": "喀麥隆"
      "CN": "中國"
      "CO": "哥倫比亞"
      "CR": "哥斯大黎加"
      "CU": "古巴"
      "CV": "維德角"
      "CW": "庫拉索"
      "CX": "聖誕島"
      "CY": "賽普勒斯"
      "CZ": "捷克共和國"
      "DE": "德國"
      "DJ": "吉布地"
      "DK": "丹麥"
      "DM": "多明尼加"
      "DO": "多明尼加共和國"
      "DZ": "阿爾及利亞"
      "EC": "厄瓜多"
      "EE": "愛沙尼亞"
      "EG": "埃及"
      "EH": "西撒哈拉"
      "ER": "厄利垂亞"
      "ES": "西班牙"
      "ET": "衣索匹亞"
      "FI": "芬蘭"
      "FJ": "斐濟"
      "FK": "福克蘭群島 (馬爾維納斯)"
      "FM": "密克羅尼西亞聯邦"
      "FO": "法羅群島"
      "FR": "法國"
      "FX": "法國，大都會區"
      "GA": "加彭"
      "GB": "英國"
      "GD": "格瑞那達"
      "GE": "喬治亞"
      "GF": "法屬圭亞那"
      "GG": "根息島"
      "GH": "迦納"
      "GI": "直布羅陀"
      "GL": "格陵蘭島"
      "GM": "甘比亞"
      "GN": "幾內亞"
      "GP": "瓜德羅普"
      "GQ": "赤道幾內亞"
      "GR": "希臘"
      "GS": "南喬治亞及南三明治群島"
      "GT": "瓜地馬拉"
      "GU": "關島"
      "GW": "幾內亞-比索"
      "GY": "蓋亞納"
      "HK": "香港"
      "HM": "赫德島及麥當勞群島"
      "HN": "宏都拉斯"
      "HR": "克羅埃西亞"
      "HT": "海地"
      "HU": "匈牙利"
      "ID": "印尼"
      "IE": "愛爾蘭"
      "IL": "以色列"
      "IM": "曼島"
      "IN": "印度"
      "IO": "英屬印度洋領土"
      "IQ": "伊拉克"
      "IR": "伊朗"
      "IS": "冰島"
      "IT": "義大利"
      "JE": "澤西島"
      "JM": "牙買加"
      "JO": "約旦"
      "JP": "日本"
      "KE": "肯亞"
      "KG": "吉爾吉斯"
      "KH": "柬埔寨"
      "KI": "吉里巴斯"
      "KM": "葛摩"
      "KN": "聖基斯及尼維斯"
      "KP": "北韓"
      "KR": "南韓"
      "KW": "科威特"
      "KY": "開曼群島"
      "KZ": "哈薩克"
      "LA": "寮國"
      "LB": "黎巴嫩"
      "LC": "聖露西亞"
      "LI": "列支敦斯登"
      "LK": "斯里蘭卡"
      "LR": "利比亞"
      "LS": "賴索托"
      "LT": "立陶宛"
      "LU": "盧森堡"
      "LV": "拉脫維亞"
      "LY": "利比亞"
      "MA": "摩洛哥"
      "MC": "摩納哥"
      "MD": "摩爾多瓦"
      "ME": "蒙特內哥羅"
      "MF": "聖馬丁"
      "MG": "馬達加斯加"
      "MH": "馬紹爾群島"
      "MK": "馬其頓"
      "ML": "馬利"
      "MM": "緬甸"
      "MN": "蒙古"
      "MO": "澳門"
      "MP": "北馬里安納群島"
      "MQ": "馬丁尼克"
      "MR": "茅利塔尼亞"
      "MS": "蒙特色拉特島"
      "MT": "馬爾他"
      "MU": "模里西斯"
      "MV": "馬爾地夫"
      "MW": "馬拉威"
      "MX": "墨西哥"
      "MY": "馬來西亞"
      "MZ": "莫三比克"
      "NA": "納米比亞"
      "NC": "新喀里多尼亞群島"
      "NE": "尼日"
      "NF": "諾福克島"
      "NG": "奈及利亞"
      "NI": "尼加拉瓜"
      "NL": "荷蘭"
      "NO": "挪威"
      "NP": "尼泊爾"
      "NR": "諾魯"
      "NU": "紐威島"
      "NZ": "紐西蘭"
      "OM": "阿曼"
      "PA": "巴拿馬"
      "PE": "祕魯"
      "PF": "法屬玻里尼西亞"
      "PG": "巴布亞紐幾內亞"
      "PH": "菲律賓"
      "PK": "巴基斯坦"
      "PL": "波蘭"
      "PM": "聖匹島及麥克隆"
      "PN": "皮特康群島"
      "PR": "波多黎各"
      "PS": "加薩走廊"
      "PS": "約旦河西岸"
      "PT": "葡萄雅"
      "PW": "帛琉"
      "PY": "巴拉圭"
      "QA": "卡達"
      "RE": "留尼旺"
      "RO": "羅馬尼亞"
      "RS": "塞爾維亞"
      "RU": "俄羅斯"
      "RW": "盧安達"
      "SA": "沙烏地阿拉伯"
      "SB": "索羅門群島"
      "SC": "塞席爾"
      "SD": "蘇丹"
      "SE": "瑞典"
      "SG": "新加坡"
      "SH": "聖赫勒拿島、亞森欣島及崔斯坦火山島"
      "SI": "斯洛維尼亞"
      "SJ": "冷岸"
      "SK": "斯洛伐克"
      "SL": "獅子山"
      "SM": "聖馬利諾"
      "SN": "塞內加爾"
      "SO": "索馬利亞"
      "SR": "蘇利南"
      "SS": "南蘇丹"
      "ST": "聖多美普林西比"
      "SV": "薩爾瓦多"
      "SX": "荷屬聖馬丁"
      "SY": "敘利亞"
      "SZ": "瑞士"
      "TC": "土克斯及開科斯群島"
      "TD": "查德"
      "TF": "法屬南部領地"
      "TG": "多哥"
      "TH": "泰國"
      "TJ": "塔吉克"
      "TK": "托克勞群島"
      "TL": "東帝汶"
      "TM": "土庫曼"
      "TN": "突尼西亞"
      "TO": "東加"
      "TR": "土耳其"
      "TT": "千里達及托巴哥"
      "TV": "吐瓦魯"
      "TW": "台灣"
      "TZ": "坦尚尼亞"
      "UA": "烏克蘭"
      "UG": "烏干達"
      "UM": "美國外島"
      "US": "美國"
      "UY": "烏拉圭"
      "UZ": "烏茲別克"
      "VA": "教廷 (梵諦岡)"
      "VC": "聖文森及格瑞那丁"
      "VE": "委內瑞拉"
      "VG": "英屬維爾京群島"
      "VI": "維爾京群島"
      "VN": "越南"
      "VU": "萬那杜"
      "WF": "瓦利斯及福杜納群島"
      "WS": "薩摩亞"
      "XK": "科索沃"
      "YE": "葉門"
      "YT": "馬約特島"
      "ZA": "南非"
      "ZM": "尚比亞"
      "ZW": "辛巴威"

    _.map ['TW', 'US', 'JP', 'KR', 'CN', 'HK', 'CA', 'GB', 'AR', 'AU', 'BR',
      'CH', 'CO', 'ID', 'IL', 'IN', 'IS', 'MX', 'NZ', 'PH', 'RU', 'SG', 'SZ',
      'TR', 'VN', 'ZA'], (v) -> [v,  countries[v]]
