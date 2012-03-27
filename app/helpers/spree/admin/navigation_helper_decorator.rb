# TODO Remove this fix once this pull request is merged and bumped: https://github.com/spree/spree/pull/1308
Spree::Admin::NavigationHelper.module_eval do
  def button(text, icon_name = nil, button_type = 'submit', options={})
    button_tag(content_tag('span', icon(icon_name) + ' ' + text), options.merge(:type => button_type))
  end

  def button_link_to(text, url, html_options = {})
    if (html_options[:method] &&
        html_options[:method].to_s.downcase != 'get' &&
        !html_options[:remote])
      form_tag(url, :method => html_options.delete(:method)) do
        button(text, html_options.delete(:icon), nil, html_options)
      end
    else
      if html_options['data-update'].nil? && html_options[:remote]
        object_name, action = url.split('/')[-2..-1]
        html_options['data-update'] = [action, object_name.singularize].join('_')
      end
      html_options.delete('data-update') unless html_options['data-update']
      link_to(text_for_button_link(text, html_options), url, html_options_for_button_link(html_options))
    end
  end
end