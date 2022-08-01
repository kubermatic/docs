var menuScrollbar;

function getHeight(el) {
  var styles = window.getComputedStyle(el);
  var height = el.offsetHeight;
  var borderTopWidth = parseFloat(styles.borderTopWidth);
  var borderBottomWidth = parseFloat(styles.borderBottomWidth);
  var paddingTop = parseFloat(styles.paddingTop);
  var paddingBottom = parseFloat(styles.paddingBottom);
  return height - borderBottomWidth - borderTopWidth - paddingTop - paddingBottom;
};

function handleSidebarMenu() {
  var sidebar = document.getElementById('sidebar');
  var sidebarHeader = document.getElementById('header-wrapper');
  var menu = sidebar.querySelector('.highlightable');
  menu.style.height = (sidebar.clientHeight - getHeight(sidebarHeader) - 40) + 'px';

  menuScrollbar = menuScrollbar || new PerfectScrollbar(menu);
  menuScrollbar.update();
};

function fallbackCopyMessage(action) {
  var actionMsg = '';
  var actionKey = (action === 'cut' ? 'X' : 'C');

  if (/iPhone|iPad/i.test(navigator.userAgent)) {
    actionMsg = 'No support :(';
  }
  else if (/Mac/i.test(navigator.userAgent)) {
    actionMsg = 'Press ⌘-' + actionKey + ' to ' + action;
  }
  else {
    actionMsg = 'Press Ctrl-' + actionKey + ' to ' + action;
  }

  return actionMsg;
};

var initMenuItemsExpand = function() {
  var menuArrows = document.querySelectorAll('.topics .menu-arrow');
  menuArrows.forEach(function(menuArrow) {
    menuArrow.addEventListener('click', function() {
      var parentClass = menuArrow.parentNode.classList;
      if (parentClass.contains('parent')) {
        parentClass.remove('parent');
      } else {
        parentClass.add('parent');
      }
    });
  });
};

var scrollToAnchor = function() {
  var hash = window.location.hash, anchor;

  if (!hash) return;

  anchor = document.querySelector('[id=' + hash.replace("#",'') + ']');

  if (!anchor) return;

  Jump(anchor, { offset: -85 });
};

var showCopyCodeTooltip = function(e, message) {
  var el = e.trigger;
  var inPre = el.parentNode.tagName === 'PRE';

  el.setAttribute('aria-label', message);
  el.classList.add('tooltipped');
  el.classList.add('tooltipped-' + (inPre ? 'w' : 's'));
};

var initClipboard = function(selector, options) {
  var clip = new ClipboardJS(selector, options || {});

  clip.on('success', function(e) {
    e.clearSelection();
    showCopyCodeTooltip(e, 'Copied to clipboard!');
  });

  clip.on('error', function(e) {
    showCopyCodeTooltip(e, fallbackCopyMessage(e.action));
  });
};

// Get Parameters from some url
var getUrlParameter = function getUrlParameter(sPageURL) {
  var url = sPageURL.split('?');
  var obj = {};
  if (url.length == 2) {
    var sURLVariables = url[1].split('&'),
        sParameterName,
        i;
    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');
      obj[sParameterName[0]] = sParameterName[1];
    }
    return obj;
  } else {
    return undefined;
  }
};

// Change styles, depending on parameters set to the image
var updateImageAttrs = function(image) {
  var o = getUrlParameter(image.src);
  if (typeof o !== "undefined") {
    var h = o["height"];
    var w = o["width"];
    var c = o["classes"];

    image.style.width = typeof w !== "undefined" ? w : "auto";
    image.style.height = typeof h !== "undefined" ? h : "auto";

    if (typeof c !== "undefined") {
      var classes = c.split(',');
      for (i = 0; i < classes.length; i++) {
        image.classList.add(classes[i]);
      }
    }
  }
};

// Execute actions on images generated from Markdown pages
// Wrap image inside a modal box (to get a full size view in a popup)
var wrapContentImages = function() {
  var images = document.querySelectorAll("div#body-inner img");
  images.forEach(function(image) {
    var link;
    if (image.parentNode.tagName === "A") return;
    link = document.createElement('a');
    link.className = 'img-lightbox-link';
    link.href = image.src
    updateImageAttrs(image);
    image.parentNode.insertBefore(link, image);
    link.appendChild(image);
  });
};

var initExpandShortcode = function() {
  var expandLabels = document.querySelectorAll('.expand-label');
  expandLabels.forEach(function(expandLabel) {
    var expandContent = expandLabel.nextElementSibling;
    var expandIcon = expandLabel.querySelector('.fas');
    var isExpanded = false;

    expandLabel.addEventListener('click', function() {
      isExpanded = !isExpanded;
      expandIcon.setAttribute('class', isExpanded ? 'fas fa-chevron-down' : 'fas fa-chevron-right');
      expandContent.setAttribute('style', isExpanded ? 'display: block;' : 'display: none;');
    });
  });
};

var initMobileMenuSidebar = function(body) {
  var sidebarOverlay = body.querySelector('#overlay');
  var sidebarBurger = body.querySelector('[data-sidebar-toggle]');

  sidebarOverlay.addEventListener('click', function() {
    var classList = body.classList;
    if (classList.contains('sidebar-hidden')) {
      classList.remove('sidebar-hidden');
    } else {
      classList.add('sidebar-hidden');
    }

    return false;
  });

  sidebarBurger.addEventListener('click', function() {
    var classList = body.classList;
    if (classList.contains('sidebar-hidden')) {
      classList.remove('sidebar-hidden');
    } else {
      classList.add('sidebar-hidden');
    }

    return false;
  });
};

// Clipboard for code blocks
var initCopyCode = function(body) {
  var codeElements = body.querySelectorAll('pre code');

  codeElements.forEach(function(codeEl) {
    var text = codeEl.textContent;

    if (text.length > 5) {
      codeEl.insertAdjacentHTML('afterend', '<span class="copy-to-clipboard" title="Copy to clipboard" />');

      codeEl.nextElementSibling.addEventListener('mouseleave', function() {
        var el = this;
        el.removeAttribute('aria-label');
        el.classList.remove('tooltipped');
        el.classList.remove('tooltipped-s');
        el.classList.remove('tooltipped-w');
      });
    }
  });

  initClipboard('.copy-to-clipboard', {
    text: function(trigger) {
      var text = trigger.previousElementSibling.textContent;
      return text.replace(/^\$\s/gm, '');
    }
  });
}

var initCopyAnchor = function(body) {
  var anchors = body.querySelectorAll('#body-inner > h2[id], #body-inner > h3[id], #body-inner > h4[id], #body-inner > h5[id], #body-inner > h6[id]');

  anchors.forEach(function(anchor) {
    var anchorWrap = document.createElement('span');
    var link = document.location.origin + document.location.pathname + '#' + anchor.id;
    anchorWrap.setAttribute('data-clipboard-text', encodeURI(link));
    anchorWrap.setAttribute('aria-label', 'Copy link to section');
    anchorWrap.className = 'copy-anchor';
    anchorWrap.textContent = anchor.textContent;

    anchorWrap.addEventListener('mouseover', function() {
      anchorWrap.classList.add('tooltipped');
      anchorWrap.classList.add('tooltipped-s');
    });

    anchorWrap.addEventListener('mouseleave', function() {
      anchorWrap.setAttribute('aria-label', 'Copy link to section');
      anchorWrap.classList.remove('tooltipped');
      anchorWrap.classList.remove('tooltipped-s');
    });

    anchor.innerHTML = null;
    anchor.appendChild(anchorWrap);
  });

  initClipboard('.copy-anchor');
};

function pageLayoutReady(fn) {
  if (document.readyState !== 'loading'){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

function pageReady(fn) {
  if (document.readyState === 'complete') {
    fn();
  } else {
    window.addEventListener('load', fn);
  }
}

pageLayoutReady(function() {
  var body = document.body;

  handleSidebarMenu();
  window.addEventListener('resize', handleSidebarMenu);
  initMobileMenuSidebar(body);
  initMenuItemsExpand();

  initCopyCode(body);
  initCopyAnchor(body);

  wrapContentImages();
  imgLightbox('img-lightbox-link', {rate: 10});
  initExpandShortcode();
});

pageReady(scrollToAnchor);
