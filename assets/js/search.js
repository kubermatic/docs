var searchModule = (function() {
  var getSearchOptions = function(searchResultsBox) {
    var searchFirstRun = true;

    var options = {
      searchClient: algoliasearch(
        'Q03DAQELCN',
        'f8b7a0497068023efe046671dd40ec62'
      ),
      indexName: "docs",
      searchFunction: function(helper) {
        if (searchFirstRun) {
          searchFirstRun = false;
          return;
        }

        helper.state.query
          ? searchResultsBox.classList.remove('search-results-box--hide')
          : searchResultsBox.classList.add('search-results-box--hide');

        helper.search();
      }
    };

    return options;
  }

  var customSearchBoxWidget = function(searchField, clearButton) {
    var renderSearchBox = function(renderOptions, isFirstRender) {
      if (isFirstRender) {
        searchField.addEventListener('input', function(event) {
          renderOptions.refine(event.target.value);
        });

        clearButton.addEventListener('click', renderOptions.clear);
      }

      searchField.value = renderOptions.query;
    };

    return instantsearch.connectors.connectSearchBox(renderSearchBox);
  }

  var initSearchProvider = function(searchField, searchResultsBox, clearButton) {
    var search = instantsearch(getSearchOptions(searchResultsBox));

    var filterSection = searchField.dataset.filter;

    var searchBoxWidget = customSearchBoxWidget(searchField, clearButton);

    var hits = instantsearch.widgets.hits({
      container: '.search-results',
      templates: {
        item: '<a href="{{relpermalink}}" title="{{title}}" class="search-results-item"><div class="search-results-item-title">{{{_highlightResult.title.value}}}</div><div class="search-results-item-content">{{{_snippetResult.content.value}}}</div><div class="search-results-item-section">in <em>{{productSection}}</em></div></a>',
        empty: '<span class="search-results-item">No results</span>',
      },
    });

    var widgets = [searchBoxWidget(), hits];

    if (filterSection) {
      widgets.unshift(instantsearch.widgets.configure({
        filters: 'productSection:' + filterSection
      }));
    }

    search.addWidgets(widgets);

    search.start();
  }

  var initSearch = function() {
    var searchBox = document.querySelector('.search-box');
    var searchField, searchResultsBox, searchResults, clearButton;

    if (!searchBox) return;
    searchField = searchBox.querySelector('.search-input');
    searchResultsBox = searchBox.querySelector('.search-results-box');
    searchResults = searchResultsBox.querySelector('.search-results');
    clearButton = searchBox.querySelector('.search-clear-icon');

    initSearchProvider(searchField, searchResultsBox, clearButton);

    document.addEventListener('keydown', function(e) {
      searchFocus(e, searchField, searchResultsBox);
      hitsFocus(e, searchResults);
    });

    document.addEventListener('click', function(e) {
      if (!findAncestor(e.target, '.search-box')) {
        searchResultsBox.classList.add('search-results-box--hide');
      }
    });
  };

  var searchFocus = function(event, searchField, searchResultsBox) {
    if (event.ctrlKey && event.key === '/') {
      event.preventDefault();
      searchField.focus();
    }
    if (event.key === 'Escape') {
      searchField.blur();
      searchResultsBox.classList.add('search-results-box--hide');
    }
  };

  var hitsFocus = function(event, searchResults) {
    var searchLinks = searchResults.querySelectorAll('a');
    var focusLinks = [].slice.call(searchLinks);
    var index = focusLinks.indexOf(document.activeElement);
    var nextIndex = 0;

    if (!searchLinks.length) return;

    if (event.keyCode === 38) {
      event.preventDefault();
      nextIndex = index > 0 ? index - 1 : 0;
      searchLinks[nextIndex].focus();
    } else if (event.keyCode === 40) {
      event.preventDefault();
      nextIndex = index + 1 < focusLinks.length ? index + 1 : index;
      searchLinks[nextIndex].focus();
    }
  };

  var findAncestor = function(el, sel) {
    while ((el = el.parentElement) && !((el.matches || el.matchesSelector).call(el,sel)));
    return el;
  };

  return {
    init: initSearch
  }
})();

pageReady(function() {
  searchModule.init();
});
