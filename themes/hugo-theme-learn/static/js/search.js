var lunrIndex, pagesIndex;

function endsWith(str, suffix) {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

// Initialize lunrjs using our generated index file
function initLunr() {
  var searchIndexUrl = document.querySelector("div[data-search-index]");

  if (!endsWith(baseurl,"/")){
    baseurl = baseurl+'/'
  };

  // First retrieve the index file
  $.getJSON(baseurl + searchIndexUrl.dataset.searchIndex)
    .done(function(index) {
      pagesIndex = index;
      // Set up lunrjs by declaring the fields we use
      // Also provide their boost level for the ranking
      lunrIndex = lunr(function() {
        this.ref("uri");
        this.field('title', {boost: 15});
        this.field("content", {boost: 5});

        this.pipeline.remove(lunr.stemmer);
        this.searchPipeline.remove(lunr.stemmer);

        // Feed lunr with each file and let lunr actually index them
        pagesIndex.forEach(function(page) {
          this.add(page);
        }, this);
      })
    })
    .fail(function(jqxhr, textStatus, error) {
      var err = textStatus + ", " + error;
      console.error("Error getting Hugo index file:", err);
    });
}

/**
 * Trigger a search in lunr and transform the result
 *
 * @param  {String} query
 * @return {Array}  results
 */
function search(queryTerm) {
  var queries = queryTerm.replace(/\s\s+/g, ' ').trim().split(" ");
  var query = "";

  if (queries.length > 1) {
    query += "+" + queries.join(" +") + "*";
  } else {
    query += queries[0]+"^100"+" "+queries[0]+"*^10"+" "+"*"+queries[0]+"^10"+" "+queries[0]+"~2^1";
  }

  return lunrIndex.search(query).map(function(result) {
    return pagesIndex.filter(function(page) {
      return page.uri === result.ref;
    })[0];
  });
}

$( document ).ready(function() {
  // Let's get started
  initLunr();

  var searchList = new autoComplete({
    /* selector for the search box element */
    selector: $("#search-by").get(0),
    /* source is the callback to perform the search */
    source: function(term, response) {
      response(search(term));
    },
    /* renderItem displays individual search results */
    renderItem: function(item, term) {
      return '<div class="autocomplete-suggestion" ' +
        'data-term="' + term + '" ' +
        'data-title="' + item.title + '" ' +
        'data-uri="'+ item.uri + '">' +
        '» ' + item.title +
        '</div>';
    },
    /* onSelect callback fires when a search suggestion is chosen */
    onSelect: function(e, term, item) {
      location.href = item.getAttribute('data-uri');
    }
  });
});
