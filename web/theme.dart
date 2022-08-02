import 'dart:html';


void init() {
  var theme = document.getElementById('theme') as InputElement;

  var elementB = document.body;

  theme.addEventListener('change', (event) {
    if(theme.checked == true) {
      if (theme.getAttribute('value') == 'light') {
        elementB?.classes.remove('light');
        elementB?.classes.toggle('dark');
        theme.setAttribute('value', 'dark');
      }
      else{
        elementB?.classes.remove('light');
        elementB?.classes.toggle('dark');
        theme.setAttribute('value', 'dark');
      }
      window.localStorage['checked'] = 'true';
    }
    else{
      elementB?.classes.remove('dark');
      elementB?.classes.toggle('light');
      theme.setAttribute('value', 'light');
      window.localStorage['checked'] = 'false';

    }
  });

  void toggleTheme(){
    if(theme.checked == true) {
      if (theme.getAttribute('value') == 'light') {
        elementB?.classes.remove('light');
        elementB?.classes.toggle('dark');
        theme.setAttribute('value', 'dark');
      }
      else{
        elementB?.classes.remove('light');
        elementB?.classes.toggle('dark');
        theme.setAttribute('value', 'dark');
      }
      window.localStorage['checked'] = 'true';
      theme.checked=true;
    }
    else{
      elementB?.classes.remove('dark');
      elementB?.classes.toggle('light');
      theme.setAttribute('value', 'light');
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
