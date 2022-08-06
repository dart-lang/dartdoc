import 'dart:html';

void init() {

  var bodyElement = document.body;

  if( bodyElement == null ){
    return;
  }

  var theme = document.getElementById('theme') as InputElement;

  theme.addEventListener('change', (event) {
    if (theme.checked==true) {
      bodyElement.setAttribute('class','dark-theme');
      theme.setAttribute('value', 'dark-theme');
      window.localStorage['colorTheme'] = 'true';
    }
    else {
      bodyElement.setAttribute('class','light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['colorTheme'] = 'false';
    }
  });

  void toggleTheme(){
    if (theme.checked==true) {
      bodyElement.setAttribute('class','dark-theme');
      theme.setAttribute('value', 'dark-theme');
      window.localStorage['colorTheme'] = 'true';
      theme.checked = true;
    }
    else {
      bodyElement.setAttribute('class','light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['colorTheme'] = 'false';
      theme.checked = false;
    }
  }

  void setChecked() {
    if (window.localStorage['colorTheme'] != null) {
      theme.checked = window.localStorage['colorTheme'] == 'true';
      toggleTheme();
    }
  }

  setChecked();
}
