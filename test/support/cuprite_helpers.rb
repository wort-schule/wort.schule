# frozen_string_literal: true

module CupriteHelpers
  # Strip the `.hidden` Tailwind class from every `data-reveal-target="item"`
  # element. The Stimulus reveal toggle and the surrounding turbo_frame
  # auto-render race on slow CI runners; flip the targets directly so system
  # tests that depend on revealed forms aren't held hostage by Stimulus
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

  # Strip `form-submission` from a form's `data-controller` so its Stimulus
  # controller stops firing a fetch on every input event. The search page
  # auto-submits the filter form on each keystroke; combined with `fill_in`
  # typing one character at a time, that yields overlapping fetches whose
  # turbo_stream responses re-render frames (including #add_words_to_list)
  # and detach elements the test is about to interact with. Disable the
  # auto-submit, set fields, then click the apply button for a single
  # deterministic form submission.
  def disable_form_auto_submit
    page.execute_script(<<~JS)
      document.querySelectorAll('form[data-controller~="form-submission"]').forEach(form => {
        const controllers = (form.dataset.controller || '').split(/\\s+/).filter(c => c !== 'form-submission');
        if (controllers.length) {
          form.dataset.controller = controllers.join(' ');
        } else {
          form.removeAttribute('data-controller');
        }
      });
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
