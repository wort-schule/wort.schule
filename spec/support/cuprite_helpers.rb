module CupriteHelpers
  # Strip the `.hidden` Tailwind class from every `data-reveal-target="item"`
  # element. The Stimulus reveal toggle and the surrounding turbo_frame
  # auto-render race on slow CI runners; flip the targets directly so feature
  # specs that depend on revealed forms aren't held hostage by Stimulus
  # binding timing.
  def force_reveal!
    page.execute_script(
      'document.querySelectorAll(\'[data-reveal-target="item"]\').forEach(el => el.classList.remove("hidden"))'
    )
  end

  # Set a <select>'s value via JS and dispatch `change`, bypassing TomSelect
  # or any other JS widget layered on top. Useful when the widget binding
  # races with Capybara on the GitHub Actions runner.
  def force_select_value(name, value)
    page.execute_script(<<~JS)
      const sel = document.querySelector('select[name="#{name}"]');
      if (sel) {
        Array.from(sel.options).forEach(o => { o.selected = (o.value === '#{value}'); });
        sel.dispatchEvent(new Event('change', { bubbles: true }));
      }
    JS
  end

  # Run a Capybara interaction that can race a Turbo re-render. The
  # rescue list covers the four ways Cuprite signals "the DOM moved under
  # us mid-action" — ObsoleteNode (node detached), CoordinatesNotFound
  # (node has no box), NodeNotFound (Ferrum lost the node id), and
  # ElementNotFound (the target was replaced before we could click).
  def with_node_churn_retry(times: 3)
    attempts = 0
    begin
      yield
    rescue Capybara::Cuprite::ObsoleteNode, Ferrum::CoordinatesNotFoundError, Ferrum::NodeNotFoundError, Capybara::ElementNotFound
      attempts += 1
      retry if attempts < times
      raise
    end
  end
end

RSpec.configure do |config|
  config.include CupriteHelpers, type: :feature
end
