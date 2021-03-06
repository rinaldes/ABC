<% if @product.present? %>
  $("#product_id").val("<%= @product.id %>");
  $("#merk").val("<%= @product.brand.name %>");
  $("#article").val("<%= @product.article %>");
  $("#disc1").val("<%= @product.margin_percent1 %> %");
  $("#disc2").val("<%= @product.margin_percent2 %> %");
  $("#disc3").val("<%= @product.margin_percent3 %> %");
  $("#disc4").val("<%= @product.margin_percent4 %> %");
  $("#disc5").val("<%= @product.margin_rp %>");
  $("#jenis").val("<%= @product.brand.id %>");
  $("#warna").val("<%= @product.full_colour.join(' / ') %>");
  $("#harga_pokok").val("<%= format_currency @product.cost_of_products %>");
  $("#harga_jual").val("<%= format_currency @product.purchase_price %>");
  $("#harga_beli").val("<%= format_currency @product.selling_price %>");
  $("#size").val("<%= @product.size.code %>");
  $("#status2").val("<%= @product.status2 %>");
  $("#status3").val("<%= @product.status3 %>");
  $("#status4").val("<%= @product.status4 %>");
  $("#m_class").val("<%= @product.m_class.name %>")
  $("#departement").val("<%= @product.brand.department.name %>")
  $("#product_image").html("<%= j(image_tag @product.image, width: '250px', height: '250px') %>")
  $("#table_size thead tr:eq(0) td").html(" ")
  $("#table_size tbody tr:eq(0) td").html(" ")
  $('.supplier_id').val('<%= @supplier.id %>')
  $('#supplier_code').val('<%= @supplier.code %>')
  $('#supplier_name').val('<%= @supplier.name %>')
  $('#alamat').val('<%= @supplier.address %>')
  <% @list_product.each_with_index do |detail, i|%>
    <% break if i > 13 %>
    $("#table_size thead tr:eq(0) td:eq(<%= i %>)").html("<%= j((detail.product_size.size_detail.size_number.to_s rescue '')) %>")
    $("#table_size tbody tr:eq(0) td:eq(<%= i %>)").html("<%= detail.available_qty %>")
    $("#table_size tbody tr:eq(1) td:eq(<%= i %>)").html("<%= detail.min_stock.to_i %>")
    $("#table_size tbody tr:eq(2) td:eq(<%= i %>)").html("<%= @list_product_in_branch.find_by_product_size_id(detail.product_size_id).available_qty.to_i rescue 0 %>")
    $("#table_size tbody tr:eq(3) td:eq(<%= i %>)").html("<%= j(text_field_tag ('quantity_number_' + (detail.product_size.size_detail.size_number.to_s rescue '')), '', class: 'quantity') %><input type='hidden' value='<%= detail.product_size_id %>'>")
  <% end %>
  nomor_ganti()
<% else %>
  alert('Your Product not present!')
<% end %>