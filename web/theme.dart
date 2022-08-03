import 'dart:html';


void init() {
  var theme = document.getElementById('theme') as InputElement;

  var elementB = document.body;

  theme.addEventListener('change', (event) {
    if(theme.checked == true) {
      if (theme.getAttribute('value') == 'light-theme') {
        elementB?.classes.remove('light-theme');
        elementB?.classes.toggle('dark-theme');
        theme.setAttribute('value', 'dark-theme');
      }
      else{
        elementB?.classes.remove('light-theme');
        elementB?.classes.toggle('dark-theme');
        theme.setAttribute('value', 'dark-theme');
      }
      window.localStorage['checked'] = 'true';
    }
    else{
      elementB?.classes.remove('dark-theme');
      elementB?.classes.toggle('light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['checked'] = 'false';

    }
  });

  void toggleTheme(){
    if(theme.checked == true) {
      if (theme.getAttribute('value') == 'light-theme') {
        elementB?.classes.remove('light-theme');
        elementB?.classes.toggle('dark-theme');
        theme.setAttribute('value', 'dark-theme');
      }
      else{
        elementB?.classes.remove('light-theme');
        elementB?.classes.toggle('dark-theme');
        theme.setAttribute('value', 'dark-theme');
      }
      window.localStorage['checked'] = 'true';
      theme.checked=true;
    }
    else{
      elementB?.classes.remove('dark-theme');
      elementB?.classes.toggle('light-theme');
      theme.setAttribute('value', 'light-theme');
      window.localStorage['checked'] = 'false';
      theme.checked=false;
    }
  }

  void setChecked(){
    if(window.localStorage['checked']!=null){
      if(window.localStorage['checked']=='true'){
        theme.checked=true;
        toggleTheme();
      }
      else {
        theme.checked = false;
        toggleTheme();
      }
    }
  }

  setChecked();
}
