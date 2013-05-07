  


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>HaxeFlixel/src/org/flixel/FlxGame.hx at dev · Beeblerox/HaxeFlixel</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="http://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <link rel="xhr-socket" href="/_sockets" />


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="LwlndM0yB63BQ7nn+ATUv6H39B6GAIewGUeG6Ody3Q4=" name="csrf-token" />

    <link href="https://a248.e.akamai.net/assets.github.com/assets/github-e0eb564ccf54f1d429657f072c2d60a7784fed7e.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://a248.e.akamai.net/assets.github.com/assets/github2-b7b4d786f5ffb5cbabe549b0ffa2261070f4c904.css" media="all" rel="stylesheet" type="text/css" />
    


      <script src="https://a248.e.akamai.net/assets.github.com/assets/frameworks-92d138f450f2960501e28397a2f63b0f100590f0.js" type="text/javascript"></script>
      <script src="https://a248.e.akamai.net/assets.github.com/assets/github-c0439b281928dd009b3a75e187d4b94c7abe5890.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="a39716dbbbdfd07db5fdeea21755f616">

        <link data-pjax-transient rel='permalink' href='/Beeblerox/HaxeFlixel/blob/9c48c80e4a66c7dc48f6260a71d518f64927b89d/src/org/flixel/FlxGame.hx'>
    <meta property="og:title" content="HaxeFlixel"/>
    <meta property="og:type" content="githubog:gitrepository"/>
    <meta property="og:url" content="https://github.com/Beeblerox/HaxeFlixel"/>
    <meta property="og:image" content="https://secure.gravatar.com/avatar/d94f85f0196036c0bb5668706705548b?s=420&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"/>
    <meta property="og:site_name" content="GitHub"/>
    <meta property="og:description" content="HaxeFlixel is an open source 2D game library written in the Haxe Language"/>
    <meta property="twitter:card" content="summary"/>
    <meta property="twitter:site" content="@GitHub">
    <meta property="twitter:title" content="Beeblerox/HaxeFlixel"/>

    <meta name="description" content="HaxeFlixel is an open source 2D game library written in the Haxe Language" />

  <link href="https://github.com/Beeblerox/HaxeFlixel/commits/dev.atom" rel="alternate" title="Recent Commits to HaxeFlixel:dev" type="application/atom+xml" />

  </head>


  <body class="logged_in page-blob linux vis-public env-production  ">
    <div id="wrapper">

      

      
      
      

      <div class="header header-logged-in true">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/">
  <span class="mega-icon mega-icon-invertocat"></span>
</a>

    <div class="divider-vertical"></div>

      <a href="/Beeblerox/HaxeFlixel/notifications" class="notification-indicator tooltipped downwards contextually-unread" title="You have unread notifications in this repository">
    <span class="mail-status unread"></span>
  </a>
  <div class="divider-vertical"></div>


      <div class="command-bar js-command-bar  in-repository">
          <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">
  <a href="/search/advanced" class="advanced-search-icon tooltipped downwards command-bar-search" id="advanced_search" title="Advanced search"><span class="mini-icon mini-icon-advanced-search "></span></a>

  <input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" data-username="henry-t" autocapitalize="off">

    <input type="hidden" name="nwo" value="Beeblerox/HaxeFlixel" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item selected">
            <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
            <input type="radio" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item">
            <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="mini-icon help tooltipped downwards" title="Show command bar help">
    <span class="mini-icon mini-icon-help"></span>
  </span>

    <input type="hidden" name="type" value="Code" />

  <input type="hidden" name="ref" value="cmdform">

  <div class="divider-vertical"></div>

    <input type="hidden" class="js-repository-name-with-owner" value="Beeblerox/HaxeFlixel"/>
    <input type="hidden" class="js-repository-branch" value="dev"/>
    <input type="hidden" class="js-repository-tree-sha" value="b73bb0c09213f62026cc1923981f76435929c0fb"/>
</form>
        <ul class="top-nav">
            <li class="explore"><a href="https://github.com/explore">Explore</a></li>
            <li><a href="https://gist.github.com">Gist</a></li>
            <li><a href="/blog">Blog</a></li>
          <li><a href="http://help.github.com">Help</a></li>
        </ul>
      </div>

    

  

    <ul id="user-links">
      <li>
        <a href="https://github.com/henry-t" class="name">
          <img height="20" src="https://secure.gravatar.com/avatar/0aae03ac8f54ecb3d567a06683a20d7e?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="20" /> henry-t
        </a>
      </li>

        <li>
          <a href="/new" id="new_repo" class="tooltipped downwards" title="Create a new repo">
            <span class="mini-icon mini-icon-create"></span>
          </a>
        </li>

        <li>
          <a href="/settings/profile" id="account_settings"
            class="tooltipped downwards"
            title="Account settings ">
            <span class="mini-icon mini-icon-account-settings"></span>
          </a>
        </li>
        <li>
          <a class="tooltipped downwards" href="/logout" data-method="post" id="logout" title="Sign out">
            <span class="mini-icon mini-icon-logout"></span>
          </a>
        </li>

    </ul>


<div class="js-new-dropdown-contents hidden">
  <ul class="dropdown-menu">
    <li>
      <a href="/new"><span class="mini-icon mini-icon-create"></span> New repository</a>
    </li>
    <li>
        <a href="https://github.com/Beeblerox/HaxeFlixel/issues/new"><span class="mini-icon mini-icon-issue-opened"></span> New issue</a>
    </li>
    <li>
    </li>
    <li>
      <a href="/organizations/new"><span class="mini-icon mini-icon-u-list"></span> New organization</a>
    </li>
  </ul>
</div>


    
  </div>
</div>

      

      

      


            <div class="site hfeed" itemscope itemtype="http://schema.org/WebPage">
      <div class="hentry">
        
        <div class="pagehead repohead instapaper_ignore readability-menu ">
          <div class="container">
            <div class="title-actions-bar">
              

<ul class="pagehead-actions">


    <li class="subscription">
      <form accept-charset="UTF-8" action="/notifications/subscribe" data-autosubmit="true" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="authenticity_token" type="hidden" value="LwlndM0yB63BQ7nn+ATUv6H39B6GAIewGUeG6Ody3Q4=" /></div>  <input id="repository_id" name="repository_id" type="hidden" value="2101031" />

    <div class="select-menu js-menu-container js-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">
          <span class="mini-icon mini-icon-unwatch"></span>
          Unwatch
        </span>
      </span>

      <div class="select-menu-modal-holder js-menu-content">
        <div class="select-menu-modal">
          <div class="select-menu-header">
            <span class="select-menu-title">Notification status</span>
            <span class="mini-icon mini-icon-remove-close js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-list js-navigation-container">

            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input id="do_included" name="do" type="radio" value="included" />
                <h4>Not watching</h4>
                <span class="description">You only receive notifications for discussions in which you participate or are @mentioned.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-watching"></span>
                  Watch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input checked="checked" id="do_subscribed" name="do" type="radio" value="subscribed" />
                <h4>Watching</h4>
                <span class="description">You receive notifications for all discussions in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-unwatch"></span>
                  Unwatch
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
              <div class="select-menu-item-text">
                <input id="do_ignore" name="do" type="radio" value="ignore" />
                <h4>Ignoring</h4>
                <span class="description">You do not receive any notifications for discussions in this repository.</span>
                <span class="js-select-button-text hidden-select-button-text">
                  <span class="mini-icon mini-icon-mute"></span>
                  Stop ignoring
                </span>
              </div>
            </div> <!-- /.select-menu-item -->

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

</form>
    </li>

    <li class="js-toggler-container js-social-container starring-container on">
      <a href="/Beeblerox/HaxeFlixel/unstar" class="minibutton js-toggler-target star-button starred upwards" title="Unstar this repo" data-remote="true" data-method="post" rel="nofollow">
        <span class="mini-icon mini-icon-remove-star"></span>
        <span class="text">Unstar</span>
      </a>
      <a href="/Beeblerox/HaxeFlixel/star" class="minibutton js-toggler-target star-button unstarred upwards" title="Star this repo" data-remote="true" data-method="post" rel="nofollow">
        <span class="mini-icon mini-icon-star"></span>
        <span class="text">Star</span>
      </a>
      <a class="social-count js-social-count" href="/Beeblerox/HaxeFlixel/stargazers">199</a>
    </li>

        <li>
          <a href="/Beeblerox/HaxeFlixel/fork" class="minibutton js-toggler-target fork-button lighter upwards" title="Fork this repo" rel="nofollow" data-method="post">
            <span class="mini-icon mini-icon-branch-create"></span>
            <span class="text">Fork</span>
          </a>
          <a href="/Beeblerox/HaxeFlixel/network" class="social-count">42</a>
        </li>


</ul>

              <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
                <span class="repo-label"><span>public</span></span>
                <span class="mega-icon mega-icon-public-repo"></span>
                <span class="author vcard">
                  <a href="/Beeblerox" class="url fn" itemprop="url" rel="author">
                  <span itemprop="title">Beeblerox</span>
                  </a></span> /
                <strong><a href="/Beeblerox/HaxeFlixel" class="js-current-repository">HaxeFlixel</a></strong>
              </h1>
            </div>

            
  <ul class="tabs">
    <li class="pulse-nav"><a href="/Beeblerox/HaxeFlixel/pulse" class="js-selected-navigation-item " data-selected-links="pulse /Beeblerox/HaxeFlixel/pulse" rel="nofollow"><span class="mini-icon mini-icon-pulse"></span></a></li>
    <li><a href="/Beeblerox/HaxeFlixel/tree/dev" class="js-selected-navigation-item selected" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /Beeblerox/HaxeFlixel/tree/dev">Code</a></li>
    <li><a href="/Beeblerox/HaxeFlixel/network" class="js-selected-navigation-item " data-selected-links="repo_network /Beeblerox/HaxeFlixel/network">Network</a></li>
    <li><a href="/Beeblerox/HaxeFlixel/pulls" class="js-selected-navigation-item " data-selected-links="repo_pulls /Beeblerox/HaxeFlixel/pulls">Pull Requests <span class='counter'>4</span></a></li>

      <li><a href="/Beeblerox/HaxeFlixel/issues" class="js-selected-navigation-item " data-selected-links="repo_issues /Beeblerox/HaxeFlixel/issues">Issues <span class='counter'>78</span></a></li>

      <li><a href="/Beeblerox/HaxeFlixel/wiki" class="js-selected-navigation-item " data-selected-links="repo_wiki /Beeblerox/HaxeFlixel/wiki">Wiki</a></li>


    <li><a href="/Beeblerox/HaxeFlixel/graphs" class="js-selected-navigation-item " data-selected-links="repo_graphs repo_contributors /Beeblerox/HaxeFlixel/graphs">Graphs</a></li>


  </ul>
  
<div class="tabnav">

  <span class="tabnav-right">
    <ul class="tabnav-tabs">
          <li><a href="/Beeblerox/HaxeFlixel/tags" class="js-selected-navigation-item tabnav-tab" data-selected-links="repo_tags /Beeblerox/HaxeFlixel/tags">Tags <span class="counter ">3</span></a></li>
    </ul>
  </span>

  <div class="tabnav-widget scope">


    <div class="select-menu js-menu-container js-select-menu js-branch-menu">
      <a class="minibutton select-menu-button js-menu-target" data-hotkey="w" data-ref="dev">
        <span class="mini-icon mini-icon-branch"></span>
        <i>branch:</i>
        <span class="js-select-button">dev</span>
      </a>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">

        <div class="select-menu-modal">
          <div class="select-menu-header">
            <span class="select-menu-title">Switch branches/tags</span>
            <span class="mini-icon mini-icon-remove-close js-menu-close"></span>
          </div> <!-- /.select-menu-header -->

          <div class="select-menu-filters">
            <div class="select-menu-text-filter">
              <input type="text" id="commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
            </div>
            <div class="select-menu-tabs">
              <ul>
                <li class="select-menu-tab">
                  <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
                </li>
                <li class="select-menu-tab">
                  <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
                </li>
              </ul>
            </div><!-- /.select-menu-tabs -->
          </div><!-- /.select-menu-filters -->

          <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket css-truncate" data-tab-filter="branches">

            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">

                <div class="select-menu-item js-navigation-item selected">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/dev/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="dev" rel="nofollow" title="dev">dev</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/flixelNME/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="flixelNME" rel="nofollow" title="flixelNME">flixelNME</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/haxe3/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="haxe3" rel="nofollow" title="haxe3">haxe3</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/texture_atlas/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="texture_atlas" rel="nofollow" title="texture_atlas">texture_atlas</a>
                </div> <!-- /.select-menu-item -->
            </div>

              <div class="select-menu-no-results">Nothing to show</div>
          </div> <!-- /.select-menu-list -->


          <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket css-truncate" data-tab-filter="tags">
            <div data-filterable-for="commitish-filter-field" data-filterable-type="substring">

                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/1.09/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="1.09" rel="nofollow" title="1.09">1.09</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/1.08/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="1.08" rel="nofollow" title="1.08">1.08</a>
                </div> <!-- /.select-menu-item -->
                <div class="select-menu-item js-navigation-item ">
                  <span class="select-menu-item-icon mini-icon mini-icon-confirm"></span>
                  <a href="/Beeblerox/HaxeFlixel/blob/1.07/src/org/flixel/FlxGame.hx" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="1.07" rel="nofollow" title="1.07">1.07</a>
                </div> <!-- /.select-menu-item -->
            </div>

            <div class="select-menu-no-results">Nothing to show</div>

          </div> <!-- /.select-menu-list -->

        </div> <!-- /.select-menu-modal -->
      </div> <!-- /.select-menu-modal-holder -->
    </div> <!-- /.select-menu -->

  </div> <!-- /.scope -->

  <ul class="tabnav-tabs">
    <li><a href="/Beeblerox/HaxeFlixel/tree/dev" class="selected js-selected-navigation-item tabnav-tab" data-selected-links="repo_source /Beeblerox/HaxeFlixel/tree/dev">Files</a></li>
    <li><a href="/Beeblerox/HaxeFlixel/commits/dev" class="js-selected-navigation-item tabnav-tab" data-selected-links="repo_commits /Beeblerox/HaxeFlixel/commits/dev">Commits</a></li>
    <li><a href="/Beeblerox/HaxeFlixel/branches" class="js-selected-navigation-item tabnav-tab" data-selected-links="repo_branches /Beeblerox/HaxeFlixel/branches" rel="nofollow">Branches <span class="counter ">4</span></a></li>
  </ul>

</div>

  
  
  


            
          </div>
        </div><!-- /.repohead -->

        <div id="js-repo-pjax-container" class="container context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:586b5d10c7a8d26f0a0e9f524415d174 -->
<!-- blob contrib frag key: views10/v8/blob_contributors:v21:586b5d10c7a8d26f0a0e9f524415d174 -->


<div id="slider">
    <div class="frame-meta">

      <p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

        <div class="breadcrumb">
          <span class='bold'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Beeblerox/HaxeFlixel/tree/dev" class="js-slide-to" data-branch="dev" data-direction="back" itemscope="url"><span itemprop="title">HaxeFlixel</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Beeblerox/HaxeFlixel/tree/dev/src" class="js-slide-to" data-branch="dev" data-direction="back" itemscope="url"><span itemprop="title">src</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Beeblerox/HaxeFlixel/tree/dev/src/org" class="js-slide-to" data-branch="dev" data-direction="back" itemscope="url"><span itemprop="title">org</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Beeblerox/HaxeFlixel/tree/dev/src/org/flixel" class="js-slide-to" data-branch="dev" data-direction="back" itemscope="url"><span itemprop="title">flixel</span></a></span><span class="separator"> / </span><strong class="final-path">FlxGame.hx</strong> <span class="js-zeroclipboard zeroclipboard-button" data-clipboard-text="src/org/flixel/FlxGame.hx" data-copied-hint="copied!" title="copy to clipboard"><span class="mini-icon mini-icon-clipboard"></span></span>
        </div>

      <a href="/Beeblerox/HaxeFlixel/find/dev" class="js-slide-to" data-hotkey="t" style="display:none">Show File Finder</a>


        
  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://secure.gravatar.com/avatar/d94f85f0196036c0bb5668706705548b?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
    <span class="author"><a href="/Beeblerox" rel="author">Beeblerox</a></span>
    <time class="js-relative-date" datetime="2013-04-13T03:20:41-07:00" title="2013-04-13 03:20:41">April 13, 2013</time>
    <div class="commit-title">
        <a href="/Beeblerox/HaxeFlixel/commit/2f1fd32dfefc9f8f7db3ea44d9458a9fe0c7b102" class="message">Merge remote-tracking branch 'origin/dev' into texture_atlas</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>3</strong> contributors</a></p>
          <a class="avatar tooltipped downwards" title="Beeblerox" href="/Beeblerox/HaxeFlixel/commits/dev/src/org/flixel/FlxGame.hx?author=Beeblerox"><img height="20" src="https://secure.gravatar.com/avatar/d94f85f0196036c0bb5668706705548b?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="20" /></a>
    <a class="avatar tooltipped downwards" title="impaler" href="/Beeblerox/HaxeFlixel/commits/dev/src/org/flixel/FlxGame.hx?author=impaler"><img height="20" src="https://secure.gravatar.com/avatar/8728f32dc1d248c90c0c451adb00e0d1?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="20" /></a>
    <a class="avatar tooltipped downwards" title="crazysam" href="/Beeblerox/HaxeFlixel/commits/dev/src/org/flixel/FlxGame.hx?author=crazysam"><img height="20" src="https://secure.gravatar.com/avatar/89a1fe99a2a15c43f5efa88f3f7010b9?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="20" /></a>


    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2>Users on GitHub who have contributed to this file</h2>
      <ul class="facebox-user-list">
        <li>
          <img height="24" src="https://secure.gravatar.com/avatar/d94f85f0196036c0bb5668706705548b?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
          <a href="/Beeblerox">Beeblerox</a>
        </li>
        <li>
          <img height="24" src="https://secure.gravatar.com/avatar/8728f32dc1d248c90c0c451adb00e0d1?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
          <a href="/impaler">impaler</a>
        </li>
        <li>
          <img height="24" src="https://secure.gravatar.com/avatar/89a1fe99a2a15c43f5efa88f3f7010b9?s=140&amp;d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png" width="24" />
          <a href="/crazysam">crazysam</a>
        </li>
      </ul>
    </div>
  </div>


    </div><!-- ./.frame-meta -->

    <div class="frames">
      <div class="frame" data-permalink-url="/Beeblerox/HaxeFlixel/blob/9c48c80e4a66c7dc48f6260a71d518f64927b89d/src/org/flixel/FlxGame.hx" data-title="HaxeFlixel/src/org/flixel/FlxGame.hx at dev · Beeblerox/HaxeFlixel · GitHub" data-type="blob">

        <div id="files" class="bubble">
          <div class="file">
            <div class="meta">
              <div class="info">
                <span class="icon"><b class="mini-icon mini-icon-text-file"></b></span>
                <span class="mode" title="File Mode">file</span>
                  <span>843 lines (757 sloc)</span>
                <span>21.003 kb</span>
              </div>
              <div class="actions">
                <div class="button-group">
                        <a class="minibutton tooltipped leftwards"
                           title="Clicking this button will automatically fork this project so you can edit the file"
                           href="/Beeblerox/HaxeFlixel/edit/dev/src/org/flixel/FlxGame.hx"
                           data-method="post" rel="nofollow">Edit</a>
                  <a href="/Beeblerox/HaxeFlixel/raw/dev/src/org/flixel/FlxGame.hx" class="button minibutton " id="raw-url">Raw</a>
                    <a href="/Beeblerox/HaxeFlixel/blame/dev/src/org/flixel/FlxGame.hx" class="button minibutton ">Blame</a>
                  <a href="/Beeblerox/HaxeFlixel/commits/dev/src/org/flixel/FlxGame.hx" class="button minibutton " rel="nofollow">History</a>
                </div><!-- /.button-group -->
              </div><!-- /.actions -->

            </div>
                <div class="blob-wrapper data type-haxe js-blob-data">
      <table class="file-code file-diff">
        <tr class="file-code-line">
          <td class="blob-line-nums">
            <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>
<span id="L80" rel="#L80">80</span>
<span id="L81" rel="#L81">81</span>
<span id="L82" rel="#L82">82</span>
<span id="L83" rel="#L83">83</span>
<span id="L84" rel="#L84">84</span>
<span id="L85" rel="#L85">85</span>
<span id="L86" rel="#L86">86</span>
<span id="L87" rel="#L87">87</span>
<span id="L88" rel="#L88">88</span>
<span id="L89" rel="#L89">89</span>
<span id="L90" rel="#L90">90</span>
<span id="L91" rel="#L91">91</span>
<span id="L92" rel="#L92">92</span>
<span id="L93" rel="#L93">93</span>
<span id="L94" rel="#L94">94</span>
<span id="L95" rel="#L95">95</span>
<span id="L96" rel="#L96">96</span>
<span id="L97" rel="#L97">97</span>
<span id="L98" rel="#L98">98</span>
<span id="L99" rel="#L99">99</span>
<span id="L100" rel="#L100">100</span>
<span id="L101" rel="#L101">101</span>
<span id="L102" rel="#L102">102</span>
<span id="L103" rel="#L103">103</span>
<span id="L104" rel="#L104">104</span>
<span id="L105" rel="#L105">105</span>
<span id="L106" rel="#L106">106</span>
<span id="L107" rel="#L107">107</span>
<span id="L108" rel="#L108">108</span>
<span id="L109" rel="#L109">109</span>
<span id="L110" rel="#L110">110</span>
<span id="L111" rel="#L111">111</span>
<span id="L112" rel="#L112">112</span>
<span id="L113" rel="#L113">113</span>
<span id="L114" rel="#L114">114</span>
<span id="L115" rel="#L115">115</span>
<span id="L116" rel="#L116">116</span>
<span id="L117" rel="#L117">117</span>
<span id="L118" rel="#L118">118</span>
<span id="L119" rel="#L119">119</span>
<span id="L120" rel="#L120">120</span>
<span id="L121" rel="#L121">121</span>
<span id="L122" rel="#L122">122</span>
<span id="L123" rel="#L123">123</span>
<span id="L124" rel="#L124">124</span>
<span id="L125" rel="#L125">125</span>
<span id="L126" rel="#L126">126</span>
<span id="L127" rel="#L127">127</span>
<span id="L128" rel="#L128">128</span>
<span id="L129" rel="#L129">129</span>
<span id="L130" rel="#L130">130</span>
<span id="L131" rel="#L131">131</span>
<span id="L132" rel="#L132">132</span>
<span id="L133" rel="#L133">133</span>
<span id="L134" rel="#L134">134</span>
<span id="L135" rel="#L135">135</span>
<span id="L136" rel="#L136">136</span>
<span id="L137" rel="#L137">137</span>
<span id="L138" rel="#L138">138</span>
<span id="L139" rel="#L139">139</span>
<span id="L140" rel="#L140">140</span>
<span id="L141" rel="#L141">141</span>
<span id="L142" rel="#L142">142</span>
<span id="L143" rel="#L143">143</span>
<span id="L144" rel="#L144">144</span>
<span id="L145" rel="#L145">145</span>
<span id="L146" rel="#L146">146</span>
<span id="L147" rel="#L147">147</span>
<span id="L148" rel="#L148">148</span>
<span id="L149" rel="#L149">149</span>
<span id="L150" rel="#L150">150</span>
<span id="L151" rel="#L151">151</span>
<span id="L152" rel="#L152">152</span>
<span id="L153" rel="#L153">153</span>
<span id="L154" rel="#L154">154</span>
<span id="L155" rel="#L155">155</span>
<span id="L156" rel="#L156">156</span>
<span id="L157" rel="#L157">157</span>
<span id="L158" rel="#L158">158</span>
<span id="L159" rel="#L159">159</span>
<span id="L160" rel="#L160">160</span>
<span id="L161" rel="#L161">161</span>
<span id="L162" rel="#L162">162</span>
<span id="L163" rel="#L163">163</span>
<span id="L164" rel="#L164">164</span>
<span id="L165" rel="#L165">165</span>
<span id="L166" rel="#L166">166</span>
<span id="L167" rel="#L167">167</span>
<span id="L168" rel="#L168">168</span>
<span id="L169" rel="#L169">169</span>
<span id="L170" rel="#L170">170</span>
<span id="L171" rel="#L171">171</span>
<span id="L172" rel="#L172">172</span>
<span id="L173" rel="#L173">173</span>
<span id="L174" rel="#L174">174</span>
<span id="L175" rel="#L175">175</span>
<span id="L176" rel="#L176">176</span>
<span id="L177" rel="#L177">177</span>
<span id="L178" rel="#L178">178</span>
<span id="L179" rel="#L179">179</span>
<span id="L180" rel="#L180">180</span>
<span id="L181" rel="#L181">181</span>
<span id="L182" rel="#L182">182</span>
<span id="L183" rel="#L183">183</span>
<span id="L184" rel="#L184">184</span>
<span id="L185" rel="#L185">185</span>
<span id="L186" rel="#L186">186</span>
<span id="L187" rel="#L187">187</span>
<span id="L188" rel="#L188">188</span>
<span id="L189" rel="#L189">189</span>
<span id="L190" rel="#L190">190</span>
<span id="L191" rel="#L191">191</span>
<span id="L192" rel="#L192">192</span>
<span id="L193" rel="#L193">193</span>
<span id="L194" rel="#L194">194</span>
<span id="L195" rel="#L195">195</span>
<span id="L196" rel="#L196">196</span>
<span id="L197" rel="#L197">197</span>
<span id="L198" rel="#L198">198</span>
<span id="L199" rel="#L199">199</span>
<span id="L200" rel="#L200">200</span>
<span id="L201" rel="#L201">201</span>
<span id="L202" rel="#L202">202</span>
<span id="L203" rel="#L203">203</span>
<span id="L204" rel="#L204">204</span>
<span id="L205" rel="#L205">205</span>
<span id="L206" rel="#L206">206</span>
<span id="L207" rel="#L207">207</span>
<span id="L208" rel="#L208">208</span>
<span id="L209" rel="#L209">209</span>
<span id="L210" rel="#L210">210</span>
<span id="L211" rel="#L211">211</span>
<span id="L212" rel="#L212">212</span>
<span id="L213" rel="#L213">213</span>
<span id="L214" rel="#L214">214</span>
<span id="L215" rel="#L215">215</span>
<span id="L216" rel="#L216">216</span>
<span id="L217" rel="#L217">217</span>
<span id="L218" rel="#L218">218</span>
<span id="L219" rel="#L219">219</span>
<span id="L220" rel="#L220">220</span>
<span id="L221" rel="#L221">221</span>
<span id="L222" rel="#L222">222</span>
<span id="L223" rel="#L223">223</span>
<span id="L224" rel="#L224">224</span>
<span id="L225" rel="#L225">225</span>
<span id="L226" rel="#L226">226</span>
<span id="L227" rel="#L227">227</span>
<span id="L228" rel="#L228">228</span>
<span id="L229" rel="#L229">229</span>
<span id="L230" rel="#L230">230</span>
<span id="L231" rel="#L231">231</span>
<span id="L232" rel="#L232">232</span>
<span id="L233" rel="#L233">233</span>
<span id="L234" rel="#L234">234</span>
<span id="L235" rel="#L235">235</span>
<span id="L236" rel="#L236">236</span>
<span id="L237" rel="#L237">237</span>
<span id="L238" rel="#L238">238</span>
<span id="L239" rel="#L239">239</span>
<span id="L240" rel="#L240">240</span>
<span id="L241" rel="#L241">241</span>
<span id="L242" rel="#L242">242</span>
<span id="L243" rel="#L243">243</span>
<span id="L244" rel="#L244">244</span>
<span id="L245" rel="#L245">245</span>
<span id="L246" rel="#L246">246</span>
<span id="L247" rel="#L247">247</span>
<span id="L248" rel="#L248">248</span>
<span id="L249" rel="#L249">249</span>
<span id="L250" rel="#L250">250</span>
<span id="L251" rel="#L251">251</span>
<span id="L252" rel="#L252">252</span>
<span id="L253" rel="#L253">253</span>
<span id="L254" rel="#L254">254</span>
<span id="L255" rel="#L255">255</span>
<span id="L256" rel="#L256">256</span>
<span id="L257" rel="#L257">257</span>
<span id="L258" rel="#L258">258</span>
<span id="L259" rel="#L259">259</span>
<span id="L260" rel="#L260">260</span>
<span id="L261" rel="#L261">261</span>
<span id="L262" rel="#L262">262</span>
<span id="L263" rel="#L263">263</span>
<span id="L264" rel="#L264">264</span>
<span id="L265" rel="#L265">265</span>
<span id="L266" rel="#L266">266</span>
<span id="L267" rel="#L267">267</span>
<span id="L268" rel="#L268">268</span>
<span id="L269" rel="#L269">269</span>
<span id="L270" rel="#L270">270</span>
<span id="L271" rel="#L271">271</span>
<span id="L272" rel="#L272">272</span>
<span id="L273" rel="#L273">273</span>
<span id="L274" rel="#L274">274</span>
<span id="L275" rel="#L275">275</span>
<span id="L276" rel="#L276">276</span>
<span id="L277" rel="#L277">277</span>
<span id="L278" rel="#L278">278</span>
<span id="L279" rel="#L279">279</span>
<span id="L280" rel="#L280">280</span>
<span id="L281" rel="#L281">281</span>
<span id="L282" rel="#L282">282</span>
<span id="L283" rel="#L283">283</span>
<span id="L284" rel="#L284">284</span>
<span id="L285" rel="#L285">285</span>
<span id="L286" rel="#L286">286</span>
<span id="L287" rel="#L287">287</span>
<span id="L288" rel="#L288">288</span>
<span id="L289" rel="#L289">289</span>
<span id="L290" rel="#L290">290</span>
<span id="L291" rel="#L291">291</span>
<span id="L292" rel="#L292">292</span>
<span id="L293" rel="#L293">293</span>
<span id="L294" rel="#L294">294</span>
<span id="L295" rel="#L295">295</span>
<span id="L296" rel="#L296">296</span>
<span id="L297" rel="#L297">297</span>
<span id="L298" rel="#L298">298</span>
<span id="L299" rel="#L299">299</span>
<span id="L300" rel="#L300">300</span>
<span id="L301" rel="#L301">301</span>
<span id="L302" rel="#L302">302</span>
<span id="L303" rel="#L303">303</span>
<span id="L304" rel="#L304">304</span>
<span id="L305" rel="#L305">305</span>
<span id="L306" rel="#L306">306</span>
<span id="L307" rel="#L307">307</span>
<span id="L308" rel="#L308">308</span>
<span id="L309" rel="#L309">309</span>
<span id="L310" rel="#L310">310</span>
<span id="L311" rel="#L311">311</span>
<span id="L312" rel="#L312">312</span>
<span id="L313" rel="#L313">313</span>
<span id="L314" rel="#L314">314</span>
<span id="L315" rel="#L315">315</span>
<span id="L316" rel="#L316">316</span>
<span id="L317" rel="#L317">317</span>
<span id="L318" rel="#L318">318</span>
<span id="L319" rel="#L319">319</span>
<span id="L320" rel="#L320">320</span>
<span id="L321" rel="#L321">321</span>
<span id="L322" rel="#L322">322</span>
<span id="L323" rel="#L323">323</span>
<span id="L324" rel="#L324">324</span>
<span id="L325" rel="#L325">325</span>
<span id="L326" rel="#L326">326</span>
<span id="L327" rel="#L327">327</span>
<span id="L328" rel="#L328">328</span>
<span id="L329" rel="#L329">329</span>
<span id="L330" rel="#L330">330</span>
<span id="L331" rel="#L331">331</span>
<span id="L332" rel="#L332">332</span>
<span id="L333" rel="#L333">333</span>
<span id="L334" rel="#L334">334</span>
<span id="L335" rel="#L335">335</span>
<span id="L336" rel="#L336">336</span>
<span id="L337" rel="#L337">337</span>
<span id="L338" rel="#L338">338</span>
<span id="L339" rel="#L339">339</span>
<span id="L340" rel="#L340">340</span>
<span id="L341" rel="#L341">341</span>
<span id="L342" rel="#L342">342</span>
<span id="L343" rel="#L343">343</span>
<span id="L344" rel="#L344">344</span>
<span id="L345" rel="#L345">345</span>
<span id="L346" rel="#L346">346</span>
<span id="L347" rel="#L347">347</span>
<span id="L348" rel="#L348">348</span>
<span id="L349" rel="#L349">349</span>
<span id="L350" rel="#L350">350</span>
<span id="L351" rel="#L351">351</span>
<span id="L352" rel="#L352">352</span>
<span id="L353" rel="#L353">353</span>
<span id="L354" rel="#L354">354</span>
<span id="L355" rel="#L355">355</span>
<span id="L356" rel="#L356">356</span>
<span id="L357" rel="#L357">357</span>
<span id="L358" rel="#L358">358</span>
<span id="L359" rel="#L359">359</span>
<span id="L360" rel="#L360">360</span>
<span id="L361" rel="#L361">361</span>
<span id="L362" rel="#L362">362</span>
<span id="L363" rel="#L363">363</span>
<span id="L364" rel="#L364">364</span>
<span id="L365" rel="#L365">365</span>
<span id="L366" rel="#L366">366</span>
<span id="L367" rel="#L367">367</span>
<span id="L368" rel="#L368">368</span>
<span id="L369" rel="#L369">369</span>
<span id="L370" rel="#L370">370</span>
<span id="L371" rel="#L371">371</span>
<span id="L372" rel="#L372">372</span>
<span id="L373" rel="#L373">373</span>
<span id="L374" rel="#L374">374</span>
<span id="L375" rel="#L375">375</span>
<span id="L376" rel="#L376">376</span>
<span id="L377" rel="#L377">377</span>
<span id="L378" rel="#L378">378</span>
<span id="L379" rel="#L379">379</span>
<span id="L380" rel="#L380">380</span>
<span id="L381" rel="#L381">381</span>
<span id="L382" rel="#L382">382</span>
<span id="L383" rel="#L383">383</span>
<span id="L384" rel="#L384">384</span>
<span id="L385" rel="#L385">385</span>
<span id="L386" rel="#L386">386</span>
<span id="L387" rel="#L387">387</span>
<span id="L388" rel="#L388">388</span>
<span id="L389" rel="#L389">389</span>
<span id="L390" rel="#L390">390</span>
<span id="L391" rel="#L391">391</span>
<span id="L392" rel="#L392">392</span>
<span id="L393" rel="#L393">393</span>
<span id="L394" rel="#L394">394</span>
<span id="L395" rel="#L395">395</span>
<span id="L396" rel="#L396">396</span>
<span id="L397" rel="#L397">397</span>
<span id="L398" rel="#L398">398</span>
<span id="L399" rel="#L399">399</span>
<span id="L400" rel="#L400">400</span>
<span id="L401" rel="#L401">401</span>
<span id="L402" rel="#L402">402</span>
<span id="L403" rel="#L403">403</span>
<span id="L404" rel="#L404">404</span>
<span id="L405" rel="#L405">405</span>
<span id="L406" rel="#L406">406</span>
<span id="L407" rel="#L407">407</span>
<span id="L408" rel="#L408">408</span>
<span id="L409" rel="#L409">409</span>
<span id="L410" rel="#L410">410</span>
<span id="L411" rel="#L411">411</span>
<span id="L412" rel="#L412">412</span>
<span id="L413" rel="#L413">413</span>
<span id="L414" rel="#L414">414</span>
<span id="L415" rel="#L415">415</span>
<span id="L416" rel="#L416">416</span>
<span id="L417" rel="#L417">417</span>
<span id="L418" rel="#L418">418</span>
<span id="L419" rel="#L419">419</span>
<span id="L420" rel="#L420">420</span>
<span id="L421" rel="#L421">421</span>
<span id="L422" rel="#L422">422</span>
<span id="L423" rel="#L423">423</span>
<span id="L424" rel="#L424">424</span>
<span id="L425" rel="#L425">425</span>
<span id="L426" rel="#L426">426</span>
<span id="L427" rel="#L427">427</span>
<span id="L428" rel="#L428">428</span>
<span id="L429" rel="#L429">429</span>
<span id="L430" rel="#L430">430</span>
<span id="L431" rel="#L431">431</span>
<span id="L432" rel="#L432">432</span>
<span id="L433" rel="#L433">433</span>
<span id="L434" rel="#L434">434</span>
<span id="L435" rel="#L435">435</span>
<span id="L436" rel="#L436">436</span>
<span id="L437" rel="#L437">437</span>
<span id="L438" rel="#L438">438</span>
<span id="L439" rel="#L439">439</span>
<span id="L440" rel="#L440">440</span>
<span id="L441" rel="#L441">441</span>
<span id="L442" rel="#L442">442</span>
<span id="L443" rel="#L443">443</span>
<span id="L444" rel="#L444">444</span>
<span id="L445" rel="#L445">445</span>
<span id="L446" rel="#L446">446</span>
<span id="L447" rel="#L447">447</span>
<span id="L448" rel="#L448">448</span>
<span id="L449" rel="#L449">449</span>
<span id="L450" rel="#L450">450</span>
<span id="L451" rel="#L451">451</span>
<span id="L452" rel="#L452">452</span>
<span id="L453" rel="#L453">453</span>
<span id="L454" rel="#L454">454</span>
<span id="L455" rel="#L455">455</span>
<span id="L456" rel="#L456">456</span>
<span id="L457" rel="#L457">457</span>
<span id="L458" rel="#L458">458</span>
<span id="L459" rel="#L459">459</span>
<span id="L460" rel="#L460">460</span>
<span id="L461" rel="#L461">461</span>
<span id="L462" rel="#L462">462</span>
<span id="L463" rel="#L463">463</span>
<span id="L464" rel="#L464">464</span>
<span id="L465" rel="#L465">465</span>
<span id="L466" rel="#L466">466</span>
<span id="L467" rel="#L467">467</span>
<span id="L468" rel="#L468">468</span>
<span id="L469" rel="#L469">469</span>
<span id="L470" rel="#L470">470</span>
<span id="L471" rel="#L471">471</span>
<span id="L472" rel="#L472">472</span>
<span id="L473" rel="#L473">473</span>
<span id="L474" rel="#L474">474</span>
<span id="L475" rel="#L475">475</span>
<span id="L476" rel="#L476">476</span>
<span id="L477" rel="#L477">477</span>
<span id="L478" rel="#L478">478</span>
<span id="L479" rel="#L479">479</span>
<span id="L480" rel="#L480">480</span>
<span id="L481" rel="#L481">481</span>
<span id="L482" rel="#L482">482</span>
<span id="L483" rel="#L483">483</span>
<span id="L484" rel="#L484">484</span>
<span id="L485" rel="#L485">485</span>
<span id="L486" rel="#L486">486</span>
<span id="L487" rel="#L487">487</span>
<span id="L488" rel="#L488">488</span>
<span id="L489" rel="#L489">489</span>
<span id="L490" rel="#L490">490</span>
<span id="L491" rel="#L491">491</span>
<span id="L492" rel="#L492">492</span>
<span id="L493" rel="#L493">493</span>
<span id="L494" rel="#L494">494</span>
<span id="L495" rel="#L495">495</span>
<span id="L496" rel="#L496">496</span>
<span id="L497" rel="#L497">497</span>
<span id="L498" rel="#L498">498</span>
<span id="L499" rel="#L499">499</span>
<span id="L500" rel="#L500">500</span>
<span id="L501" rel="#L501">501</span>
<span id="L502" rel="#L502">502</span>
<span id="L503" rel="#L503">503</span>
<span id="L504" rel="#L504">504</span>
<span id="L505" rel="#L505">505</span>
<span id="L506" rel="#L506">506</span>
<span id="L507" rel="#L507">507</span>
<span id="L508" rel="#L508">508</span>
<span id="L509" rel="#L509">509</span>
<span id="L510" rel="#L510">510</span>
<span id="L511" rel="#L511">511</span>
<span id="L512" rel="#L512">512</span>
<span id="L513" rel="#L513">513</span>
<span id="L514" rel="#L514">514</span>
<span id="L515" rel="#L515">515</span>
<span id="L516" rel="#L516">516</span>
<span id="L517" rel="#L517">517</span>
<span id="L518" rel="#L518">518</span>
<span id="L519" rel="#L519">519</span>
<span id="L520" rel="#L520">520</span>
<span id="L521" rel="#L521">521</span>
<span id="L522" rel="#L522">522</span>
<span id="L523" rel="#L523">523</span>
<span id="L524" rel="#L524">524</span>
<span id="L525" rel="#L525">525</span>
<span id="L526" rel="#L526">526</span>
<span id="L527" rel="#L527">527</span>
<span id="L528" rel="#L528">528</span>
<span id="L529" rel="#L529">529</span>
<span id="L530" rel="#L530">530</span>
<span id="L531" rel="#L531">531</span>
<span id="L532" rel="#L532">532</span>
<span id="L533" rel="#L533">533</span>
<span id="L534" rel="#L534">534</span>
<span id="L535" rel="#L535">535</span>
<span id="L536" rel="#L536">536</span>
<span id="L537" rel="#L537">537</span>
<span id="L538" rel="#L538">538</span>
<span id="L539" rel="#L539">539</span>
<span id="L540" rel="#L540">540</span>
<span id="L541" rel="#L541">541</span>
<span id="L542" rel="#L542">542</span>
<span id="L543" rel="#L543">543</span>
<span id="L544" rel="#L544">544</span>
<span id="L545" rel="#L545">545</span>
<span id="L546" rel="#L546">546</span>
<span id="L547" rel="#L547">547</span>
<span id="L548" rel="#L548">548</span>
<span id="L549" rel="#L549">549</span>
<span id="L550" rel="#L550">550</span>
<span id="L551" rel="#L551">551</span>
<span id="L552" rel="#L552">552</span>
<span id="L553" rel="#L553">553</span>
<span id="L554" rel="#L554">554</span>
<span id="L555" rel="#L555">555</span>
<span id="L556" rel="#L556">556</span>
<span id="L557" rel="#L557">557</span>
<span id="L558" rel="#L558">558</span>
<span id="L559" rel="#L559">559</span>
<span id="L560" rel="#L560">560</span>
<span id="L561" rel="#L561">561</span>
<span id="L562" rel="#L562">562</span>
<span id="L563" rel="#L563">563</span>
<span id="L564" rel="#L564">564</span>
<span id="L565" rel="#L565">565</span>
<span id="L566" rel="#L566">566</span>
<span id="L567" rel="#L567">567</span>
<span id="L568" rel="#L568">568</span>
<span id="L569" rel="#L569">569</span>
<span id="L570" rel="#L570">570</span>
<span id="L571" rel="#L571">571</span>
<span id="L572" rel="#L572">572</span>
<span id="L573" rel="#L573">573</span>
<span id="L574" rel="#L574">574</span>
<span id="L575" rel="#L575">575</span>
<span id="L576" rel="#L576">576</span>
<span id="L577" rel="#L577">577</span>
<span id="L578" rel="#L578">578</span>
<span id="L579" rel="#L579">579</span>
<span id="L580" rel="#L580">580</span>
<span id="L581" rel="#L581">581</span>
<span id="L582" rel="#L582">582</span>
<span id="L583" rel="#L583">583</span>
<span id="L584" rel="#L584">584</span>
<span id="L585" rel="#L585">585</span>
<span id="L586" rel="#L586">586</span>
<span id="L587" rel="#L587">587</span>
<span id="L588" rel="#L588">588</span>
<span id="L589" rel="#L589">589</span>
<span id="L590" rel="#L590">590</span>
<span id="L591" rel="#L591">591</span>
<span id="L592" rel="#L592">592</span>
<span id="L593" rel="#L593">593</span>
<span id="L594" rel="#L594">594</span>
<span id="L595" rel="#L595">595</span>
<span id="L596" rel="#L596">596</span>
<span id="L597" rel="#L597">597</span>
<span id="L598" rel="#L598">598</span>
<span id="L599" rel="#L599">599</span>
<span id="L600" rel="#L600">600</span>
<span id="L601" rel="#L601">601</span>
<span id="L602" rel="#L602">602</span>
<span id="L603" rel="#L603">603</span>
<span id="L604" rel="#L604">604</span>
<span id="L605" rel="#L605">605</span>
<span id="L606" rel="#L606">606</span>
<span id="L607" rel="#L607">607</span>
<span id="L608" rel="#L608">608</span>
<span id="L609" rel="#L609">609</span>
<span id="L610" rel="#L610">610</span>
<span id="L611" rel="#L611">611</span>
<span id="L612" rel="#L612">612</span>
<span id="L613" rel="#L613">613</span>
<span id="L614" rel="#L614">614</span>
<span id="L615" rel="#L615">615</span>
<span id="L616" rel="#L616">616</span>
<span id="L617" rel="#L617">617</span>
<span id="L618" rel="#L618">618</span>
<span id="L619" rel="#L619">619</span>
<span id="L620" rel="#L620">620</span>
<span id="L621" rel="#L621">621</span>
<span id="L622" rel="#L622">622</span>
<span id="L623" rel="#L623">623</span>
<span id="L624" rel="#L624">624</span>
<span id="L625" rel="#L625">625</span>
<span id="L626" rel="#L626">626</span>
<span id="L627" rel="#L627">627</span>
<span id="L628" rel="#L628">628</span>
<span id="L629" rel="#L629">629</span>
<span id="L630" rel="#L630">630</span>
<span id="L631" rel="#L631">631</span>
<span id="L632" rel="#L632">632</span>
<span id="L633" rel="#L633">633</span>
<span id="L634" rel="#L634">634</span>
<span id="L635" rel="#L635">635</span>
<span id="L636" rel="#L636">636</span>
<span id="L637" rel="#L637">637</span>
<span id="L638" rel="#L638">638</span>
<span id="L639" rel="#L639">639</span>
<span id="L640" rel="#L640">640</span>
<span id="L641" rel="#L641">641</span>
<span id="L642" rel="#L642">642</span>
<span id="L643" rel="#L643">643</span>
<span id="L644" rel="#L644">644</span>
<span id="L645" rel="#L645">645</span>
<span id="L646" rel="#L646">646</span>
<span id="L647" rel="#L647">647</span>
<span id="L648" rel="#L648">648</span>
<span id="L649" rel="#L649">649</span>
<span id="L650" rel="#L650">650</span>
<span id="L651" rel="#L651">651</span>
<span id="L652" rel="#L652">652</span>
<span id="L653" rel="#L653">653</span>
<span id="L654" rel="#L654">654</span>
<span id="L655" rel="#L655">655</span>
<span id="L656" rel="#L656">656</span>
<span id="L657" rel="#L657">657</span>
<span id="L658" rel="#L658">658</span>
<span id="L659" rel="#L659">659</span>
<span id="L660" rel="#L660">660</span>
<span id="L661" rel="#L661">661</span>
<span id="L662" rel="#L662">662</span>
<span id="L663" rel="#L663">663</span>
<span id="L664" rel="#L664">664</span>
<span id="L665" rel="#L665">665</span>
<span id="L666" rel="#L666">666</span>
<span id="L667" rel="#L667">667</span>
<span id="L668" rel="#L668">668</span>
<span id="L669" rel="#L669">669</span>
<span id="L670" rel="#L670">670</span>
<span id="L671" rel="#L671">671</span>
<span id="L672" rel="#L672">672</span>
<span id="L673" rel="#L673">673</span>
<span id="L674" rel="#L674">674</span>
<span id="L675" rel="#L675">675</span>
<span id="L676" rel="#L676">676</span>
<span id="L677" rel="#L677">677</span>
<span id="L678" rel="#L678">678</span>
<span id="L679" rel="#L679">679</span>
<span id="L680" rel="#L680">680</span>
<span id="L681" rel="#L681">681</span>
<span id="L682" rel="#L682">682</span>
<span id="L683" rel="#L683">683</span>
<span id="L684" rel="#L684">684</span>
<span id="L685" rel="#L685">685</span>
<span id="L686" rel="#L686">686</span>
<span id="L687" rel="#L687">687</span>
<span id="L688" rel="#L688">688</span>
<span id="L689" rel="#L689">689</span>
<span id="L690" rel="#L690">690</span>
<span id="L691" rel="#L691">691</span>
<span id="L692" rel="#L692">692</span>
<span id="L693" rel="#L693">693</span>
<span id="L694" rel="#L694">694</span>
<span id="L695" rel="#L695">695</span>
<span id="L696" rel="#L696">696</span>
<span id="L697" rel="#L697">697</span>
<span id="L698" rel="#L698">698</span>
<span id="L699" rel="#L699">699</span>
<span id="L700" rel="#L700">700</span>
<span id="L701" rel="#L701">701</span>
<span id="L702" rel="#L702">702</span>
<span id="L703" rel="#L703">703</span>
<span id="L704" rel="#L704">704</span>
<span id="L705" rel="#L705">705</span>
<span id="L706" rel="#L706">706</span>
<span id="L707" rel="#L707">707</span>
<span id="L708" rel="#L708">708</span>
<span id="L709" rel="#L709">709</span>
<span id="L710" rel="#L710">710</span>
<span id="L711" rel="#L711">711</span>
<span id="L712" rel="#L712">712</span>
<span id="L713" rel="#L713">713</span>
<span id="L714" rel="#L714">714</span>
<span id="L715" rel="#L715">715</span>
<span id="L716" rel="#L716">716</span>
<span id="L717" rel="#L717">717</span>
<span id="L718" rel="#L718">718</span>
<span id="L719" rel="#L719">719</span>
<span id="L720" rel="#L720">720</span>
<span id="L721" rel="#L721">721</span>
<span id="L722" rel="#L722">722</span>
<span id="L723" rel="#L723">723</span>
<span id="L724" rel="#L724">724</span>
<span id="L725" rel="#L725">725</span>
<span id="L726" rel="#L726">726</span>
<span id="L727" rel="#L727">727</span>
<span id="L728" rel="#L728">728</span>
<span id="L729" rel="#L729">729</span>
<span id="L730" rel="#L730">730</span>
<span id="L731" rel="#L731">731</span>
<span id="L732" rel="#L732">732</span>
<span id="L733" rel="#L733">733</span>
<span id="L734" rel="#L734">734</span>
<span id="L735" rel="#L735">735</span>
<span id="L736" rel="#L736">736</span>
<span id="L737" rel="#L737">737</span>
<span id="L738" rel="#L738">738</span>
<span id="L739" rel="#L739">739</span>
<span id="L740" rel="#L740">740</span>
<span id="L741" rel="#L741">741</span>
<span id="L742" rel="#L742">742</span>
<span id="L743" rel="#L743">743</span>
<span id="L744" rel="#L744">744</span>
<span id="L745" rel="#L745">745</span>
<span id="L746" rel="#L746">746</span>
<span id="L747" rel="#L747">747</span>
<span id="L748" rel="#L748">748</span>
<span id="L749" rel="#L749">749</span>
<span id="L750" rel="#L750">750</span>
<span id="L751" rel="#L751">751</span>
<span id="L752" rel="#L752">752</span>
<span id="L753" rel="#L753">753</span>
<span id="L754" rel="#L754">754</span>
<span id="L755" rel="#L755">755</span>
<span id="L756" rel="#L756">756</span>
<span id="L757" rel="#L757">757</span>
<span id="L758" rel="#L758">758</span>
<span id="L759" rel="#L759">759</span>
<span id="L760" rel="#L760">760</span>
<span id="L761" rel="#L761">761</span>
<span id="L762" rel="#L762">762</span>
<span id="L763" rel="#L763">763</span>
<span id="L764" rel="#L764">764</span>
<span id="L765" rel="#L765">765</span>
<span id="L766" rel="#L766">766</span>
<span id="L767" rel="#L767">767</span>
<span id="L768" rel="#L768">768</span>
<span id="L769" rel="#L769">769</span>
<span id="L770" rel="#L770">770</span>
<span id="L771" rel="#L771">771</span>
<span id="L772" rel="#L772">772</span>
<span id="L773" rel="#L773">773</span>
<span id="L774" rel="#L774">774</span>
<span id="L775" rel="#L775">775</span>
<span id="L776" rel="#L776">776</span>
<span id="L777" rel="#L777">777</span>
<span id="L778" rel="#L778">778</span>
<span id="L779" rel="#L779">779</span>
<span id="L780" rel="#L780">780</span>
<span id="L781" rel="#L781">781</span>
<span id="L782" rel="#L782">782</span>
<span id="L783" rel="#L783">783</span>
<span id="L784" rel="#L784">784</span>
<span id="L785" rel="#L785">785</span>
<span id="L786" rel="#L786">786</span>
<span id="L787" rel="#L787">787</span>
<span id="L788" rel="#L788">788</span>
<span id="L789" rel="#L789">789</span>
<span id="L790" rel="#L790">790</span>
<span id="L791" rel="#L791">791</span>
<span id="L792" rel="#L792">792</span>
<span id="L793" rel="#L793">793</span>
<span id="L794" rel="#L794">794</span>
<span id="L795" rel="#L795">795</span>
<span id="L796" rel="#L796">796</span>
<span id="L797" rel="#L797">797</span>
<span id="L798" rel="#L798">798</span>
<span id="L799" rel="#L799">799</span>
<span id="L800" rel="#L800">800</span>
<span id="L801" rel="#L801">801</span>
<span id="L802" rel="#L802">802</span>
<span id="L803" rel="#L803">803</span>
<span id="L804" rel="#L804">804</span>
<span id="L805" rel="#L805">805</span>
<span id="L806" rel="#L806">806</span>
<span id="L807" rel="#L807">807</span>
<span id="L808" rel="#L808">808</span>
<span id="L809" rel="#L809">809</span>
<span id="L810" rel="#L810">810</span>
<span id="L811" rel="#L811">811</span>
<span id="L812" rel="#L812">812</span>
<span id="L813" rel="#L813">813</span>
<span id="L814" rel="#L814">814</span>
<span id="L815" rel="#L815">815</span>
<span id="L816" rel="#L816">816</span>
<span id="L817" rel="#L817">817</span>
<span id="L818" rel="#L818">818</span>
<span id="L819" rel="#L819">819</span>
<span id="L820" rel="#L820">820</span>
<span id="L821" rel="#L821">821</span>
<span id="L822" rel="#L822">822</span>
<span id="L823" rel="#L823">823</span>
<span id="L824" rel="#L824">824</span>
<span id="L825" rel="#L825">825</span>
<span id="L826" rel="#L826">826</span>
<span id="L827" rel="#L827">827</span>
<span id="L828" rel="#L828">828</span>
<span id="L829" rel="#L829">829</span>
<span id="L830" rel="#L830">830</span>
<span id="L831" rel="#L831">831</span>
<span id="L832" rel="#L832">832</span>
<span id="L833" rel="#L833">833</span>
<span id="L834" rel="#L834">834</span>
<span id="L835" rel="#L835">835</span>
<span id="L836" rel="#L836">836</span>
<span id="L837" rel="#L837">837</span>
<span id="L838" rel="#L838">838</span>
<span id="L839" rel="#L839">839</span>
<span id="L840" rel="#L840">840</span>
<span id="L841" rel="#L841">841</span>
<span id="L842" rel="#L842">842</span>
<span id="L843" rel="#L843">843</span>

          </td>
          <td class="blob-line-code">
                  <div class="highlight"><pre><div class='line' id='LC1'><span class="kn">package</span> <span class="nn">org.flixel</span><span class="p">;</span></div><div class='line' id='LC2'><br/></div><div class='line' id='LC3'><span class="kn">import</span> <span class="nn">nme.Lib</span><span class="p">;</span></div><div class='line' id='LC4'><span class="kn">import</span> <span class="nn">nme.Assets</span><span class="p">;</span></div><div class='line' id='LC5'><span class="kn">import</span> <span class="nn">nme.display.Bitmap</span><span class="p">;</span></div><div class='line' id='LC6'><span class="kn">import</span> <span class="nn">nme.display.BitmapData</span><span class="p">;</span></div><div class='line' id='LC7'><span class="kn">import</span> <span class="nn">nme.display.Graphics</span><span class="p">;</span></div><div class='line' id='LC8'><span class="kn">import</span> <span class="nn">nme.display.Sprite</span><span class="p">;</span></div><div class='line' id='LC9'><span class="kn">import</span> <span class="nn">nme.display.StageAlign</span><span class="p">;</span></div><div class='line' id='LC10'><span class="kn">import</span> <span class="nn">nme.display.StageScaleMode</span><span class="p">;</span></div><div class='line' id='LC11'><span class="kn">import</span> <span class="nn">nme.events.Event</span><span class="p">;</span></div><div class='line' id='LC12'><span class="kn">import</span> <span class="nn">nme.media.Sound</span><span class="p">;</span></div><div class='line' id='LC13'><span class="kn">import</span> <span class="nn">nme.text.TextField</span><span class="p">;</span></div><div class='line' id='LC14'><span class="kn">import</span> <span class="nn">nme.text.TextFormat</span><span class="p">;</span></div><div class='line' id='LC15'><span class="kn">import</span> <span class="nn">nme.text.TextFormatAlign</span><span class="p">;</span></div><div class='line' id='LC16'><span class="kn">import</span> <span class="nn">org.flixel.plugin.pxText.PxBitmapFont</span><span class="p">;</span></div><div class='line' id='LC17'><span class="kn">import</span> <span class="nn">org.flixel.system.layer.Atlas</span><span class="p">;</span></div><div class='line' id='LC18'><span class="kn">import</span> <span class="nn">org.flixel.system.layer.TileSheetData</span><span class="p">;</span></div><div class='line' id='LC19'><span class="kn">import</span> <span class="nn">org.flixel.system.input.FlxInputs</span><span class="p">;</span></div><div class='line' id='LC20'><br/></div><div class='line' id='LC21'><span class="cp">#if flash</span></div><div class='line' id='LC22'><span class="kn">import</span> <span class="nn">flash.text.AntiAliasType</span><span class="p">;</span></div><div class='line' id='LC23'><span class="kn">import</span> <span class="nn">flash.text.GridFitType</span><span class="p">;</span></div><div class='line' id='LC24'><span class="cp">#end</span></div><div class='line' id='LC25'><br/></div><div class='line' id='LC26'><span class="kn">import</span> <span class="nn">org.flixel.plugin.TimerManager</span><span class="p">;</span></div><div class='line' id='LC27'><span class="kn">import</span> <span class="nn">org.flixel.system.FlxReplay</span><span class="p">;</span></div><div class='line' id='LC28'><br/></div><div class='line' id='LC29'><span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC30'><span class="kn">import</span> <span class="nn">org.flixel.system.FlxDebugger</span><span class="p">;</span></div><div class='line' id='LC31'><span class="cp">#end</span></div><div class='line' id='LC32'><br/></div><div class='line' id='LC33'><span class="cm">/**</span></div><div class='line' id='LC34'><span class="cm"> * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.</span></div><div class='line' id='LC35'><span class="cm"> * It is a long and sloppy file that you shouldn&#39;t have to worry about too much!</span></div><div class='line' id='LC36'><span class="cm"> * It is basically only used to create your game object in the first place,</span></div><div class='line' id='LC37'><span class="cm"> * after that FlxG and FlxState have all the useful stuff you actually need.</span></div><div class='line' id='LC38'><span class="cm"> */</span></div><div class='line' id='LC39'><span class="kd">class</span> <span class="nc">FlxGame</span> <span class="kd">extends</span> <span class="nc">Sprite</span></div><div class='line' id='LC40'><span class="p">{</span></div><div class='line' id='LC41'><br/></div><div class='line' id='LC42'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">junk</span><span class="p">:</span><span class="nc">String</span><span class="p">;</span></div><div class='line' id='LC43'>	<span class="cm">/**</span></div><div class='line' id='LC44'><span class="cm">	 * Sets 0, -, and + to control the global volume sound volume.</span></div><div class='line' id='LC45'><span class="cm">	 * @default true</span></div><div class='line' id='LC46'><span class="cm">	 */</span></div><div class='line' id='LC47'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">useSoundHotKeys</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC48'>	<span class="cm">/**</span></div><div class='line' id='LC49'><span class="cm">	 * Current game state.</span></div><div class='line' id='LC50'><span class="cm">	 */</span></div><div class='line' id='LC51'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_state</span><span class="p">:</span><span class="nc">FlxState</span><span class="p">;</span></div><div class='line' id='LC52'>	<span class="cm">/**</span></div><div class='line' id='LC53'><span class="cm">	 * Mouse cursor.</span></div><div class='line' id='LC54'><span class="cm">	 */</span></div><div class='line' id='LC55'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_inputContainer</span><span class="p">:</span><span class="nc">Sprite</span><span class="p">;</span></div><div class='line' id='LC56'>	<span class="cm">/**</span></div><div class='line' id='LC57'><span class="cm">	 * Class type of the initial/first game state for the game, usually MenuState or something like that.</span></div><div class='line' id='LC58'><span class="cm">	 */</span></div><div class='line' id='LC59'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_iState</span><span class="p">:</span><span class="nc">Class</span><span class="p">&lt;</span><span class="nc">FlxState</span><span class="p">&gt;;</span></div><div class='line' id='LC60'>	<span class="cm">/**</span></div><div class='line' id='LC61'><span class="cm">	 * Total number of milliseconds elapsed since game start.</span></div><div class='line' id='LC62'><span class="cm">	 */</span></div><div class='line' id='LC63'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_total</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC64'>	<span class="cm">/**</span></div><div class='line' id='LC65'><span class="cm">	 * Helper variable to help calculate elapsed time.</span></div><div class='line' id='LC66'><span class="cm">	 */</span></div><div class='line' id='LC67'>	<span class="kd">public</span> <span class="kd">static</span> <span class="kd">var</span> <span class="vi">_mark</span><span class="err">(default,</span> <span class="err">null)</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC68'>	<span class="cm">/**</span></div><div class='line' id='LC69'><span class="cm">	 * Total number of milliseconds elapsed since last update loop.</span></div><div class='line' id='LC70'><span class="cm">	 * Counts down as we step through the game loop.</span></div><div class='line' id='LC71'><span class="cm">	 */</span></div><div class='line' id='LC72'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_accumulator</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC73'>	<span class="cm">/**</span></div><div class='line' id='LC74'><span class="cm">	 * Whether the Flash player lost focus.</span></div><div class='line' id='LC75'><span class="cm">	 */</span></div><div class='line' id='LC76'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_lostFocus</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC77'>	<span class="cm">/**</span></div><div class='line' id='LC78'><span class="cm">	 * Milliseconds of time since last step. Supposed to be internal.</span></div><div class='line' id='LC79'><span class="cm">	 */</span></div><div class='line' id='LC80'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_elapsedMS</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC81'>	<span class="cm">/**</span></div><div class='line' id='LC82'><span class="cm">	 * Milliseconds of time per step of the game loop.  FlashEvent.g. 60 fps = 16ms. Supposed to be internal.</span></div><div class='line' id='LC83'><span class="cm">	 */</span></div><div class='line' id='LC84'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_step</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC85'>	<span class="cm">/**</span></div><div class='line' id='LC86'><span class="cm">	 * Optimization so we don&#39;t have to divide _step by 1000 to get its value in seconds every frame. Supposed to be internal.</span></div><div class='line' id='LC87'><span class="cm">	 */</span></div><div class='line' id='LC88'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_stepSeconds</span><span class="p">:</span><span class="nc">Float</span><span class="p">;</span></div><div class='line' id='LC89'>	<span class="cm">/**</span></div><div class='line' id='LC90'><span class="cm">	 * Framerate of the Flash player (NOT the game loop). Default = 30.</span></div><div class='line' id='LC91'><span class="cm">	 */</span></div><div class='line' id='LC92'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_flashFramerate</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC93'>	<span class="cm">/**</span></div><div class='line' id='LC94'><span class="cm">	 * Max allowable accumulation (see _accumulator).</span></div><div class='line' id='LC95'><span class="cm">	 * Should always (and automatically) be set to roughly 2x the flash player framerate.</span></div><div class='line' id='LC96'><span class="cm">	 */</span></div><div class='line' id='LC97'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_maxAccumulation</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC98'>	<span class="cm">/**</span></div><div class='line' id='LC99'><span class="cm">	 * If a state change was requested, the new state object is stored here until we switch to it.</span></div><div class='line' id='LC100'><span class="cm">	 */</span></div><div class='line' id='LC101'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_requestedState</span><span class="p">:</span><span class="nc">FlxState</span><span class="p">;</span></div><div class='line' id='LC102'>	<span class="cm">/**</span></div><div class='line' id='LC103'><span class="cm">	 * A flag for keeping track of whether a game reset was requested or not.</span></div><div class='line' id='LC104'><span class="cm">	 */</span></div><div class='line' id='LC105'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_requestedReset</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC106'>	<span class="cm">/**</span></div><div class='line' id='LC107'><span class="cm">	 * The &quot;focus lost&quot; screen (see &lt;code&gt;createFocusScreen()&lt;/code&gt;).</span></div><div class='line' id='LC108'><span class="cm">	 */</span></div><div class='line' id='LC109'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_focus</span><span class="p">:</span><span class="nc">Sprite</span><span class="p">;</span></div><div class='line' id='LC110'>	<span class="cm">/**</span></div><div class='line' id='LC111'><span class="cm">	 * The sound tray display container (see &lt;code&gt;createSoundTray()&lt;/code&gt;).</span></div><div class='line' id='LC112'><span class="cm">	 */</span></div><div class='line' id='LC113'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_soundTray</span><span class="p">:</span><span class="nc">Sprite</span><span class="p">;</span></div><div class='line' id='LC114'>	<span class="cm">/**</span></div><div class='line' id='LC115'><span class="cm">	 * Helps us auto-hide the sound tray after a volume change.</span></div><div class='line' id='LC116'><span class="cm">	 */</span></div><div class='line' id='LC117'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_soundTrayTimer</span><span class="p">:</span><span class="nc">Float</span><span class="p">;</span></div><div class='line' id='LC118'>	<span class="cm">/**</span></div><div class='line' id='LC119'><span class="cm">	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.</span></div><div class='line' id='LC120'><span class="cm">	 */</span></div><div class='line' id='LC121'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_updateSoundTray</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC122'>	<span class="cm">/**</span></div><div class='line' id='LC123'><span class="cm">	 * Helps display the volume bars on the sound tray.</span></div><div class='line' id='LC124'><span class="cm">	 */</span></div><div class='line' id='LC125'>	<span class="kd">private</span> <span class="kd">var</span> <span class="vi">_soundTrayBars</span><span class="p">:</span><span class="nc">Array</span><span class="p">&lt;</span><span class="nc">Bitmap</span><span class="p">&gt;;</span></div><div class='line' id='LC126'><br/></div><div class='line' id='LC127'>	<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC128'>	<span class="cm">/**</span></div><div class='line' id='LC129'><span class="cm">	 * The debugger overlay object.</span></div><div class='line' id='LC130'><span class="cm">	 */</span></div><div class='line' id='LC131'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_debugger</span><span class="p">:</span><span class="nc">FlxDebugger</span><span class="p">;</span></div><div class='line' id='LC132'>	<span class="cm">/**</span></div><div class='line' id='LC133'><span class="cm">	 * A handy boolean that keeps track of whether the debugger exists and is currently visible.</span></div><div class='line' id='LC134'><span class="cm">	 */</span></div><div class='line' id='LC135'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_debuggerUp</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC136'>	<span class="cp">#end</span></div><div class='line' id='LC137'><br/></div><div class='line' id='LC138'>	<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC139'>	<span class="cm">/**</span></div><div class='line' id='LC140'><span class="cm">	 * Container for a game replay object.</span></div><div class='line' id='LC141'><span class="cm">	 */</span></div><div class='line' id='LC142'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replay</span><span class="p">:</span><span class="nc">FlxReplay</span><span class="p">;</span></div><div class='line' id='LC143'>	<span class="cm">/**</span></div><div class='line' id='LC144'><span class="cm">	 * Flag for whether a playback of a recording was requested.</span></div><div class='line' id='LC145'><span class="cm">	 */</span></div><div class='line' id='LC146'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replayRequested</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC147'>	<span class="cm">/**</span></div><div class='line' id='LC148'><span class="cm">	 * Flag for whether a new recording was requested.</span></div><div class='line' id='LC149'><span class="cm">	 */</span></div><div class='line' id='LC150'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_recordingRequested</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC151'>	<span class="cm">/**</span></div><div class='line' id='LC152'><span class="cm">	 * Flag for whether a replay is currently playing.</span></div><div class='line' id='LC153'><span class="cm">	 */</span></div><div class='line' id='LC154'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replaying</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC155'>	<span class="cm">/**</span></div><div class='line' id='LC156'><span class="cm">	 * Flag for whether a new recording is being made.</span></div><div class='line' id='LC157'><span class="cm">	 */</span></div><div class='line' id='LC158'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_recording</span><span class="p">:</span><span class="nc">Bool</span><span class="p">;</span></div><div class='line' id='LC159'>	<span class="cm">/**</span></div><div class='line' id='LC160'><span class="cm">	 * Array that keeps track of keypresses that can cancel a replay.</span></div><div class='line' id='LC161'><span class="cm">	 * Handy for skipping cutscenes or getting out of attract modes!</span></div><div class='line' id='LC162'><span class="cm">	 */</span></div><div class='line' id='LC163'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replayCancelKeys</span><span class="p">:</span><span class="nc">Array</span><span class="p">&lt;</span><span class="nc">String</span><span class="p">&gt;;</span></div><div class='line' id='LC164'>	<span class="cm">/**</span></div><div class='line' id='LC165'><span class="cm">	 * Helps time out a replay if necessary.</span></div><div class='line' id='LC166'><span class="cm">	 */</span></div><div class='line' id='LC167'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replayTimer</span><span class="p">:</span><span class="nc">Int</span><span class="p">;</span></div><div class='line' id='LC168'>	<span class="cm">/**</span></div><div class='line' id='LC169'><span class="cm">	 * This function, if set, is triggered when the callback stops playing.</span></div><div class='line' id='LC170'><span class="cm">	 */</span></div><div class='line' id='LC171'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">_replayCallback</span><span class="p">:</span><span class="nc">Void</span><span class="kt">-&gt;</span><span class="nc">Void</span><span class="p">;</span></div><div class='line' id='LC172'>	<span class="cp">#end</span></div><div class='line' id='LC173'><br/></div><div class='line' id='LC174'>	<span class="cm">/**</span></div><div class='line' id='LC175'><span class="cm">	 * Instantiate a new game object.</span></div><div class='line' id='LC176'><span class="cm">	 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).</span></div><div class='line' id='LC177'><span class="cm">	 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).</span></div><div class='line' id='LC178'><span class="cm">	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).</span></div><div class='line' id='LC179'><span class="cm">	 * @param	Zoom			The default level of zoom for the game&#39;s cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.</span></div><div class='line' id='LC180'><span class="cm">	 * @param	GameFramerate	How frequently the game should update (default is 60 times per second).</span></div><div class='line' id='LC181'><span class="cm">	 * @param	FlashFramerate	Sets the actual display framerate for Flash player (default is 30 times per second).</span></div><div class='line' id='LC182'><span class="cm">	 * @param	UseSystemCursor	Whether to use the default OS mouse pointer, or to use custom flixel ones.</span></div><div class='line' id='LC183'><span class="cm">	 */</span></div><div class='line' id='LC184'>	<span class="kd">public</span> <span class="kd">function</span> <span class="nf">new</span><span class="p">(</span><span class="nv">GameSizeX</span><span class="p">:</span><span class="nc">Int</span><span class="p">,</span> <span class="nv">GameSizeY</span><span class="p">:</span><span class="nc">Int</span><span class="p">,</span> <span class="nv">InitialState</span><span class="p">:</span><span class="nc">Class</span><span class="p">&lt;</span><span class="nc">FlxState</span><span class="p">&gt;,</span> <span class="nv">Zoom</span><span class="p">:</span><span class="nc">Float</span> <span class="o">=</span> <span class="mi">1</span><span class="p">,</span> <span class="nv">GameFramerate</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="mi">60</span><span class="p">,</span> <span class="nv">FlashFramerate</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="mi">30</span><span class="p">)</span></div><div class='line' id='LC185'>	<span class="p">{</span></div><div class='line' id='LC186'>		<span class="kr">super</span><span class="p">();</span></div><div class='line' id='LC187'><br/></div><div class='line' id='LC188'>		<span class="c1">//super high priority init stuff (focus, mouse, etc)</span></div><div class='line' id='LC189'>		<span class="n">_lostFocus</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC190'>		<span class="n">_focus</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Sprite</span><span class="p">();</span></div><div class='line' id='LC191'>		<span class="n">_focus</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC192'>		<span class="n">_soundTray</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Sprite</span><span class="p">();</span></div><div class='line' id='LC193'>		<span class="n">_inputContainer</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Sprite</span><span class="p">();</span></div><div class='line' id='LC194'><br/></div><div class='line' id='LC195'>		<span class="c1">//basic display and update setup stuff</span></div><div class='line' id='LC196'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">init</span><span class="p">(</span><span class="kr">this</span><span class="p">,</span> <span class="n">GameSizeX</span><span class="p">,</span> <span class="n">GameSizeY</span><span class="p">,</span> <span class="n">Zoom</span><span class="p">);</span></div><div class='line' id='LC197'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">framerate</span> <span class="o">=</span> <span class="n">GameFramerate</span><span class="p">;</span></div><div class='line' id='LC198'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">flashFramerate</span> <span class="o">=</span> <span class="n">FlashFramerate</span><span class="p">;</span></div><div class='line' id='LC199'>		<span class="n">_accumulator</span> <span class="o">=</span> <span class="n">_step</span><span class="p">;</span></div><div class='line' id='LC200'>		<span class="n">_total</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC201'>		<span class="n">_mark</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC202'>		<span class="n">_state</span> <span class="o">=</span> <span class="kc">null</span><span class="p">;</span></div><div class='line' id='LC203'>		<span class="n">useSoundHotKeys</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC204'><br/></div><div class='line' id='LC205'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC206'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">debug</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC207'>		<span class="n">_debuggerUp</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC208'>		<span class="cp">#end</span></div><div class='line' id='LC209'><br/></div><div class='line' id='LC210'>		<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC211'>		<span class="c1">//replay data</span></div><div class='line' id='LC212'>		<span class="n">_replay</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">FlxReplay</span><span class="p">();</span></div><div class='line' id='LC213'>		<span class="n">_replayRequested</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC214'>		<span class="n">_recordingRequested</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC215'>		<span class="n">_replaying</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC216'>		<span class="n">_recording</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC217'>		<span class="cp">#end</span></div><div class='line' id='LC218'><br/></div><div class='line' id='LC219'>		<span class="c1">//then get ready to create the game object for real</span></div><div class='line' id='LC220'>		<span class="n">_iState</span> <span class="o">=</span> <span class="n">InitialState</span><span class="p">;</span></div><div class='line' id='LC221'>		<span class="n">_requestedState</span> <span class="o">=</span> <span class="kc">null</span><span class="p">;</span></div><div class='line' id='LC222'>		<span class="n">_requestedReset</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC223'><br/></div><div class='line' id='LC224'>		<span class="n">addEventListener</span><span class="p">(</span><span class="n">Event</span><span class="o">.</span><span class="n">ADDED_TO_STAGE</span><span class="p">,</span> <span class="n">create</span><span class="p">);</span></div><div class='line' id='LC225'>	<span class="p">}</span></div><div class='line' id='LC226'><br/></div><div class='line' id='LC227'>	<span class="cm">/**</span></div><div class='line' id='LC228'><span class="cm">	 * Makes the little volume tray slide out.</span></div><div class='line' id='LC229'><span class="cm">	 * @param	Silent	Whether or not it should beep.</span></div><div class='line' id='LC230'><span class="cm">	 */</span></div><div class='line' id='LC231'>	<span class="kd">public</span> <span class="kd">function</span> <span class="nf">showSoundTray</span><span class="p">(</span><span class="nv">Silent</span><span class="p">:</span><span class="nc">Bool</span> <span class="o">=</span> <span class="nv">false</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC232'>	<span class="p">{</span></div><div class='line' id='LC233'>		<span class="kr">if</span> <span class="p">(</span><span class="o">!</span><span class="n">Silent</span><span class="p">)</span></div><div class='line' id='LC234'>		<span class="p">{</span></div><div class='line' id='LC235'>			<span class="n">FlxG</span><span class="o">.</span><span class="n">play</span><span class="p">(</span><span class="n">FlxAssets</span><span class="o">.</span><span class="n">sndBeep</span><span class="p">);</span></div><div class='line' id='LC236'>		<span class="p">}</span></div><div class='line' id='LC237'>		<span class="n">_soundTrayTimer</span> <span class="o">=</span> <span class="mi">1</span><span class="p">;</span></div><div class='line' id='LC238'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">y</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC239'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC240'>		<span class="n">_updateSoundTray</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC241'>		<span class="kd">var</span> <span class="nv">globalVolume</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Math</span><span class="o">.</span><span class="n">round</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">volume</span> <span class="o">*</span> <span class="mi">10</span><span class="p">);</span></div><div class='line' id='LC242'>		<span class="kr">if</span> <span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">mute</span><span class="p">)</span></div><div class='line' id='LC243'>		<span class="p">{</span></div><div class='line' id='LC244'>			<span class="n">globalVolume</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC245'>		<span class="p">}</span></div><div class='line' id='LC246'>		<span class="kr">for</span> <span class="p">(</span><span class="n">i</span> <span class="kr">in</span> <span class="mi">0</span><span class="o">...</span><span class="p">(</span><span class="n">_soundTrayBars</span><span class="o">.</span><span class="n">length</span><span class="p">))</span></div><div class='line' id='LC247'>		<span class="p">{</span></div><div class='line' id='LC248'>			<span class="kr">if</span> <span class="p">(</span><span class="n">i</span> <span class="o">&lt;</span> <span class="n">globalVolume</span><span class="p">)</span> <span class="n">_soundTrayBars</span><span class="p">[</span><span class="n">i</span><span class="p">]</span><span class="o">.</span><span class="n">alpha</span> <span class="o">=</span> <span class="mi">1</span><span class="p">;</span></div><div class='line' id='LC249'>			<span class="kr">else</span> <span class="n">_soundTrayBars</span><span class="p">[</span><span class="n">i</span><span class="p">]</span><span class="o">.</span><span class="n">alpha</span> <span class="o">=</span> <span class="mi">0</span><span class="o">.</span><span class="mi">5</span><span class="p">;</span></div><div class='line' id='LC250'>		<span class="p">}</span></div><div class='line' id='LC251'>	<span class="p">}</span></div><div class='line' id='LC252'><br/></div><div class='line' id='LC253'>	<span class="cm">/**</span></div><div class='line' id='LC254'><span class="cm">	 * Internal event handler for input and focus.</span></div><div class='line' id='LC255'><span class="cm">	 * @param	FlashEvent	Flash event.</span></div><div class='line' id='LC256'><span class="cm">	 */</span></div><div class='line' id='LC257'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">onFocus</span><span class="p">(</span><span class="nv">FlashEvent</span><span class="p">:</span><span class="nc">Event</span> <span class="o">=</span> <span class="nv">null</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC258'>	<span class="p">{</span></div><div class='line' id='LC259'>		<span class="n">_lostFocus</span> <span class="o">=</span> <span class="n">_focus</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC260'>		<span class="n">stage</span><span class="o">.</span><span class="n">frameRate</span> <span class="o">=</span> <span class="n">_flashFramerate</span><span class="p">;</span></div><div class='line' id='LC261'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">resumeSounds</span><span class="p">();</span></div><div class='line' id='LC262'>		<span class="n">FlxInputs</span><span class="o">.</span><span class="n">onFocus</span><span class="p">();</span></div><div class='line' id='LC263'><br/></div><div class='line' id='LC264'>		<span class="n">_state</span><span class="o">.</span><span class="n">onFocus</span><span class="p">();</span></div><div class='line' id='LC265'>	<span class="p">}</span></div><div class='line' id='LC266'><br/></div><div class='line' id='LC267'>	<span class="cm">/**</span></div><div class='line' id='LC268'><span class="cm">	 * Internal event handler for input and focus.</span></div><div class='line' id='LC269'><span class="cm">	 * @param	FlashEvent	Flash event.</span></div><div class='line' id='LC270'><span class="cm">	 */</span></div><div class='line' id='LC271'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">onFocusLost</span><span class="p">(</span><span class="nv">FlashEvent</span><span class="p">:</span><span class="nc">Event</span> <span class="o">=</span> <span class="nv">null</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC272'>	<span class="p">{</span></div><div class='line' id='LC273'>		<span class="n">_lostFocus</span> <span class="o">=</span> <span class="n">_focus</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC274'>		<span class="n">stage</span><span class="o">.</span><span class="n">frameRate</span> <span class="o">=</span> <span class="mi">10</span><span class="p">;</span></div><div class='line' id='LC275'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">pauseSounds</span><span class="p">();</span></div><div class='line' id='LC276'>		<span class="n">FlxInputs</span><span class="o">.</span><span class="n">onFocusLost</span><span class="p">();</span></div><div class='line' id='LC277'><br/></div><div class='line' id='LC278'>		<span class="n">_state</span><span class="o">.</span><span class="n">onFocusLost</span><span class="p">();</span></div><div class='line' id='LC279'>	<span class="p">}</span></div><div class='line' id='LC280'><br/></div><div class='line' id='LC281'>	<span class="cm">/**</span></div><div class='line' id='LC282'><span class="cm">	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.</span></div><div class='line' id='LC283'><span class="cm">	 * @param	FlashEvent	Flash event.</span></div><div class='line' id='LC284'><span class="cm">	 */</span></div><div class='line' id='LC285'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">onEnterFrame</span><span class="p">(</span><span class="nv">FlashEvent</span><span class="p">:</span><span class="nc">Event</span> <span class="o">=</span> <span class="nv">null</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC286'>	<span class="p">{</span>			</div><div class='line' id='LC287'>		<span class="n">_mark</span> <span class="o">=</span> <span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">();</span></div><div class='line' id='LC288'>		<span class="n">_elapsedMS</span> <span class="o">=</span> <span class="n">_mark</span> <span class="o">-</span> <span class="n">_total</span><span class="p">;</span></div><div class='line' id='LC289'>		<span class="n">_total</span> <span class="o">=</span> <span class="n">_mark</span><span class="p">;</span></div><div class='line' id='LC290'><br/></div><div class='line' id='LC291'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_updateSoundTray</span><span class="p">)</span></div><div class='line' id='LC292'>			<span class="n">updateSoundTray</span><span class="p">(</span><span class="n">_elapsedMS</span><span class="p">);</span></div><div class='line' id='LC293'><br/></div><div class='line' id='LC294'>		<span class="kr">if</span><span class="p">(</span><span class="o">!</span><span class="n">_lostFocus</span><span class="p">)</span></div><div class='line' id='LC295'>		<span class="p">{</span></div><div class='line' id='LC296'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC297'>			<span class="kr">if</span><span class="p">((</span><span class="n">_debugger</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span> <span class="o">&amp;&amp;</span> <span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">paused</span><span class="p">)</span></div><div class='line' id='LC298'>			<span class="p">{</span></div><div class='line' id='LC299'>				<span class="kr">if</span><span class="p">(</span><span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">stepRequested</span><span class="p">)</span></div><div class='line' id='LC300'>				<span class="p">{</span></div><div class='line' id='LC301'>					<span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">stepRequested</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC302'>					<span class="n">step</span><span class="p">();</span></div><div class='line' id='LC303'>				<span class="p">}</span></div><div class='line' id='LC304'>			<span class="p">}</span></div><div class='line' id='LC305'>			<span class="kr">else</span></div><div class='line' id='LC306'>			<span class="p">{</span></div><div class='line' id='LC307'>			<span class="cp">#end</span></div><div class='line' id='LC308'>				<span class="n">_accumulator</span> <span class="o">+=</span> <span class="n">_elapsedMS</span><span class="p">;</span></div><div class='line' id='LC309'>				<span class="kr">if</span> <span class="p">(</span><span class="n">_accumulator</span> <span class="o">&gt;</span> <span class="n">_maxAccumulation</span><span class="p">)</span></div><div class='line' id='LC310'>				<span class="p">{</span></div><div class='line' id='LC311'>					<span class="n">_accumulator</span> <span class="o">=</span> <span class="n">_maxAccumulation</span><span class="p">;</span></div><div class='line' id='LC312'>				<span class="p">}</span></div><div class='line' id='LC313'>				<span class="c1">// TODO: You may uncomment following lines</span></div><div class='line' id='LC314'>				<span class="c1">//while (_accumulator &gt; _step)</span></div><div class='line' id='LC315'>				<span class="kr">while</span><span class="p">(</span><span class="n">_accumulator</span> <span class="o">&gt;=</span> <span class="n">_step</span><span class="p">)</span></div><div class='line' id='LC316'>				<span class="p">{</span></div><div class='line' id='LC317'>					<span class="n">step</span><span class="p">();</span></div><div class='line' id='LC318'>					<span class="n">_accumulator</span> <span class="o">=</span> <span class="n">_accumulator</span> <span class="o">-</span> <span class="n">_step</span><span class="p">;</span> </div><div class='line' id='LC319'>				<span class="p">}</span></div><div class='line' id='LC320'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC321'>			<span class="p">}</span></div><div class='line' id='LC322'>			<span class="cp">#end</span></div><div class='line' id='LC323'><br/></div><div class='line' id='LC324'>			<span class="n">FlxBasic</span><span class="o">.</span><span class="n">_VISIBLECOUNT</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC325'>			<span class="n">draw</span><span class="p">();</span></div><div class='line' id='LC326'><br/></div><div class='line' id='LC327'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC328'>			<span class="kr">if</span><span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC329'>			<span class="p">{</span></div><div class='line' id='LC330'>				<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">flash</span><span class="p">(</span><span class="n">_elapsedMS</span><span class="p">);</span></div><div class='line' id='LC331'>				<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">visibleObjects</span><span class="p">(</span><span class="n">FlxBasic</span><span class="o">.</span><span class="n">_VISIBLECOUNT</span><span class="p">);</span></div><div class='line' id='LC332'>				<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">update</span><span class="p">();</span></div><div class='line' id='LC333'>				<span class="n">_debugger</span><span class="o">.</span><span class="n">watch</span><span class="o">.</span><span class="n">update</span><span class="p">();</span></div><div class='line' id='LC334'>			<span class="p">}</span></div><div class='line' id='LC335'>			<span class="cp">#end</span></div><div class='line' id='LC336'><br/></div><div class='line' id='LC337'>		<span class="p">}</span></div><div class='line' id='LC338'>	<span class="p">}</span></div><div class='line' id='LC339'><br/></div><div class='line' id='LC340'>	<span class="cm">/**</span></div><div class='line' id='LC341'><span class="cm">	 * Internal method to create a new instance of iState and reset the game.</span></div><div class='line' id='LC342'><span class="cm">	 * This gets called when the game is created, as well as when a new state is requested.</span></div><div class='line' id='LC343'><span class="cm">	 */</span></div><div class='line' id='LC344'>	<span class="kd">private</span> <span class="kd">inline</span> <span class="kd">function</span> <span class="nf">resetGame</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC345'>	<span class="p">{</span></div><div class='line' id='LC346'>		<span class="n">_requestedState</span> <span class="o">=</span> <span class="n">Type</span><span class="o">.</span><span class="n">createInstance</span><span class="p">(</span><span class="n">_iState</span><span class="p">,</span> <span class="p">[]);</span></div><div class='line' id='LC347'><br/></div><div class='line' id='LC348'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC349'>		<span class="kr">if</span> <span class="p">(</span><span class="n">Std</span><span class="o">.</span><span class="n">is</span><span class="p">(</span><span class="n">_requestedState</span><span class="p">,</span> <span class="n">FlxSubState</span><span class="p">))</span></div><div class='line' id='LC350'>		<span class="p">{</span></div><div class='line' id='LC351'>			<span class="kr">throw</span> <span class="s2">&quot;You can&#39;t set FlxSubState class instance as the state for you game&quot;</span><span class="p">;</span></div><div class='line' id='LC352'>		<span class="p">}</span></div><div class='line' id='LC353'>		<span class="cp">#end</span></div><div class='line' id='LC354'><br/></div><div class='line' id='LC355'>		<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC356'>		<span class="n">_replayTimer</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC357'>		<span class="n">_replayCancelKeys</span> <span class="o">=</span> <span class="kc">null</span><span class="p">;</span></div><div class='line' id='LC358'>		<span class="cp">#end</span></div><div class='line' id='LC359'><br/></div><div class='line' id='LC360'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">reset</span><span class="p">();</span></div><div class='line' id='LC361'>	<span class="p">}</span></div><div class='line' id='LC362'><br/></div><div class='line' id='LC363'>	<span class="cm">/**</span></div><div class='line' id='LC364'><span class="cm">	 * If there is a state change requested during the update loop,</span></div><div class='line' id='LC365'><span class="cm">	 * this function handles actual destroying the old state and related processes,</span></div><div class='line' id='LC366'><span class="cm">	 * and calls creates on the new state and plugs it into the game object.</span></div><div class='line' id='LC367'><span class="cm">	 */</span></div><div class='line' id='LC368'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">switchState</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC369'>	<span class="p">{</span> </div><div class='line' id='LC370'>		<span class="c1">//Basic reset stuff</span></div><div class='line' id='LC371'>		<span class="cp">#if !flash</span></div><div class='line' id='LC372'>		<span class="n">PxBitmapFont</span><span class="o">.</span><span class="n">clearStorage</span><span class="p">();</span></div><div class='line' id='LC373'>		<span class="n">Atlas</span><span class="o">.</span><span class="n">clearAtlasCache</span><span class="p">();</span></div><div class='line' id='LC374'>		<span class="n">TileSheetData</span><span class="o">.</span><span class="n">clear</span><span class="p">();</span></div><div class='line' id='LC375'>		<span class="cp">#end</span></div><div class='line' id='LC376'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">clearBitmapCache</span><span class="p">();</span></div><div class='line' id='LC377'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">resetCameras</span><span class="p">();</span></div><div class='line' id='LC378'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">resetInput</span><span class="p">();</span></div><div class='line' id='LC379'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">destroySounds</span><span class="p">();</span></div><div class='line' id='LC380'><br/></div><div class='line' id='LC381'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC382'>		<span class="c1">//Clear the debugger overlay&#39;s Watch window</span></div><div class='line' id='LC383'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debugger</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC384'>		<span class="p">{</span></div><div class='line' id='LC385'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">watch</span><span class="o">.</span><span class="n">removeAll</span><span class="p">();</span></div><div class='line' id='LC386'>		<span class="p">}</span></div><div class='line' id='LC387'>		<span class="cp">#end</span></div><div class='line' id='LC388'><br/></div><div class='line' id='LC389'>		<span class="c1">//Clear any timers left in the timer manager</span></div><div class='line' id='LC390'>		<span class="kd">var</span> <span class="nv">timerManager</span><span class="p">:</span><span class="nc">TimerManager</span> <span class="o">=</span> <span class="n">FlxTimer</span><span class="o">.</span><span class="n">manager</span><span class="p">;</span></div><div class='line' id='LC391'>		<span class="kr">if</span> <span class="p">(</span><span class="n">timerManager</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC392'>		<span class="p">{</span></div><div class='line' id='LC393'>			<span class="n">timerManager</span><span class="o">.</span><span class="n">clear</span><span class="p">();</span></div><div class='line' id='LC394'>		<span class="p">}</span></div><div class='line' id='LC395'><br/></div><div class='line' id='LC396'>		<span class="c1">//Destroy the old state (if there is an old state)</span></div><div class='line' id='LC397'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_state</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC398'>		<span class="p">{</span></div><div class='line' id='LC399'>			<span class="n">_state</span><span class="o">.</span><span class="n">destroy</span><span class="p">();</span></div><div class='line' id='LC400'>		<span class="p">}</span></div><div class='line' id='LC401'><br/></div><div class='line' id='LC402'>		<span class="c1">//Finally assign and create the new state</span></div><div class='line' id='LC403'>		<span class="n">_state</span> <span class="o">=</span> <span class="n">_requestedState</span><span class="p">;</span></div><div class='line' id='LC404'>		<span class="n">_state</span><span class="o">.</span><span class="n">create</span><span class="p">();</span></div><div class='line' id='LC405'>	<span class="p">}</span></div><div class='line' id='LC406'><br/></div><div class='line' id='LC407'>	<span class="cm">/**</span></div><div class='line' id='LC408'><span class="cm">	 * This is the main game update logic section.</span></div><div class='line' id='LC409'><span class="cm">	 * The onEnterFrame() handler is in charge of calling this</span></div><div class='line' id='LC410'><span class="cm">	 * the appropriate number of times each frame.</span></div><div class='line' id='LC411'><span class="cm">	 * This block handles state changes, replays, all that good stuff.</span></div><div class='line' id='LC412'><span class="cm">	 */</span></div><div class='line' id='LC413'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">step</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC414'>	<span class="p">{</span></div><div class='line' id='LC415'>		<span class="c1">//handle game reset request</span></div><div class='line' id='LC416'>		<span class="kr">if</span><span class="p">(</span><span class="n">_requestedReset</span><span class="p">)</span></div><div class='line' id='LC417'>		<span class="p">{</span></div><div class='line' id='LC418'>			<span class="n">resetGame</span><span class="p">();</span></div><div class='line' id='LC419'>			<span class="n">_requestedReset</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC420'>		<span class="p">}</span></div><div class='line' id='LC421'><br/></div><div class='line' id='LC422'>		<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC423'>		<span class="c1">//handle replay-related requests</span></div><div class='line' id='LC424'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_recordingRequested</span><span class="p">)</span></div><div class='line' id='LC425'>		<span class="p">{</span></div><div class='line' id='LC426'>			<span class="n">_recordingRequested</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC427'>			<span class="n">_replay</span><span class="o">.</span><span class="n">create</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">globalSeed</span><span class="p">);</span></div><div class='line' id='LC428'>			<span class="n">_recording</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC429'><br/></div><div class='line' id='LC430'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC431'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">recording</span><span class="p">();</span></div><div class='line' id='LC432'>			<span class="n">FlxG</span><span class="o">.</span><span class="n">log</span><span class="p">(</span><span class="s2">&quot;FLIXEL: starting new flixel gameplay record.&quot;</span><span class="p">);</span></div><div class='line' id='LC433'>			<span class="cp">#end</span></div><div class='line' id='LC434'>		<span class="p">}</span></div><div class='line' id='LC435'>		<span class="kr">else</span> <span class="kr">if</span> <span class="p">(</span><span class="n">_replayRequested</span><span class="p">)</span></div><div class='line' id='LC436'>		<span class="p">{</span></div><div class='line' id='LC437'>			<span class="n">_replayRequested</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC438'>			<span class="n">_replay</span><span class="o">.</span><span class="n">rewind</span><span class="p">();</span></div><div class='line' id='LC439'>			<span class="n">FlxG</span><span class="o">.</span><span class="n">globalSeed</span> <span class="o">=</span> <span class="n">_replay</span><span class="o">.</span><span class="n">seed</span><span class="p">;</span></div><div class='line' id='LC440'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC441'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">playing</span><span class="p">();</span></div><div class='line' id='LC442'>			<span class="cp">#end</span></div><div class='line' id='LC443'>			<span class="n">_replaying</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC444'>		<span class="p">}</span></div><div class='line' id='LC445'>		<span class="cp">#end</span></div><div class='line' id='LC446'><br/></div><div class='line' id='LC447'>		<span class="c1">//finally actually step through the game physics</span></div><div class='line' id='LC448'>		<span class="n">FlxBasic</span><span class="o">.</span><span class="n">_ACTIVECOUNT</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC449'><br/></div><div class='line' id='LC450'>		<span class="cp">#if (cpp &amp;&amp; thread)</span></div><div class='line' id='LC451'>		<span class="n">threadSync</span><span class="o">.</span><span class="n">push</span><span class="p">(</span><span class="kc">true</span><span class="p">);</span></div><div class='line' id='LC452'>		<span class="cp">#else</span></div><div class='line' id='LC453'>		<span class="n">update</span><span class="p">();</span></div><div class='line' id='LC454'>		<span class="cp">#end</span></div><div class='line' id='LC455'><br/></div><div class='line' id='LC456'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC457'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC458'>		<span class="p">{</span></div><div class='line' id='LC459'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">activeObjects</span><span class="p">(</span><span class="n">FlxBasic</span><span class="o">.</span><span class="n">_ACTIVECOUNT</span><span class="p">);</span></div><div class='line' id='LC460'>		<span class="p">}</span></div><div class='line' id='LC461'>		<span class="cp">#end</span></div><div class='line' id='LC462'>	<span class="p">}</span></div><div class='line' id='LC463'><br/></div><div class='line' id='LC464'>	<span class="cp">#if (cpp &amp;&amp; thread)</span></div><div class='line' id='LC465'>	<span class="c1">// push &#39;true&#39; into this array to trigger an update. push &#39;false&#39; to terminate update thread.</span></div><div class='line' id='LC466'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">threadSync</span><span class="p">:</span><span class="nc">cpp.vm.Deque</span><span class="p">&lt;</span><span class="nc">Bool</span><span class="p">&gt;;</span></div><div class='line' id='LC467'><br/></div><div class='line' id='LC468'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">threadedUpdate</span><span class="p">():</span><span class="nc">Void</span> </div><div class='line' id='LC469'>	<span class="p">{</span></div><div class='line' id='LC470'>		<span class="kr">while</span> <span class="p">(</span><span class="n">threadSync</span><span class="o">.</span><span class="n">pop</span><span class="p">(</span><span class="kc">true</span><span class="p">))</span></div><div class='line' id='LC471'>			<span class="n">update</span><span class="p">();</span></div><div class='line' id='LC472'>	<span class="p">}</span></div><div class='line' id='LC473'>	<span class="cp">#end</span></div><div class='line' id='LC474'><br/></div><div class='line' id='LC475'>	<span class="cm">/**</span></div><div class='line' id='LC476'><span class="cm">	 * This function just updates the soundtray object.</span></div><div class='line' id='LC477'><span class="cm">	 */</span></div><div class='line' id='LC478'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">updateSoundTray</span><span class="p">(</span><span class="nv">MS</span><span class="p">:</span><span class="nc">Float</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC479'>	<span class="p">{</span></div><div class='line' id='LC480'>		<span class="c1">//animate stupid sound tray thing</span></div><div class='line' id='LC481'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_soundTrayTimer</span> <span class="o">&gt;</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC482'>		<span class="p">{</span></div><div class='line' id='LC483'>			<span class="n">_soundTrayTimer</span> <span class="o">-=</span> <span class="n">MS</span><span class="o">/</span><span class="mi">1000</span><span class="p">;</span></div><div class='line' id='LC484'>		<span class="p">}</span></div><div class='line' id='LC485'>		<span class="kr">else</span> <span class="kr">if</span> <span class="p">(</span><span class="n">_soundTray</span><span class="o">.</span><span class="n">y</span> <span class="o">&gt;</span> <span class="o">-</span><span class="n">_soundTray</span><span class="o">.</span><span class="n">height</span><span class="p">)</span></div><div class='line' id='LC486'>		<span class="p">{</span></div><div class='line' id='LC487'>			<span class="n">_soundTray</span><span class="o">.</span><span class="n">y</span> <span class="o">-=</span> <span class="p">(</span><span class="n">MS</span> <span class="o">/</span> <span class="mi">1000</span><span class="p">)</span> <span class="o">*</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">height</span> <span class="o">*</span> <span class="mi">2</span><span class="p">;</span></div><div class='line' id='LC488'>			<span class="kr">if</span> <span class="p">(</span><span class="n">_soundTray</span><span class="o">.</span><span class="n">y</span> <span class="o">&lt;=</span> <span class="o">-</span><span class="n">_soundTray</span><span class="o">.</span><span class="n">height</span><span class="p">)</span></div><div class='line' id='LC489'>			<span class="p">{</span></div><div class='line' id='LC490'>				<span class="n">_soundTray</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC491'>				<span class="n">_updateSoundTray</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC492'><br/></div><div class='line' id='LC493'>				<span class="c1">//Save sound preferences</span></div><div class='line' id='LC494'>				<span class="kd">var</span> <span class="nv">soundPrefs</span><span class="p">:</span><span class="nc">FlxSave</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">FlxSave</span><span class="p">();</span></div><div class='line' id='LC495'>				<span class="kr">if</span> <span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">bind</span><span class="p">(</span><span class="s2">&quot;flixel&quot;</span><span class="p">))</span></div><div class='line' id='LC496'>				<span class="p">{</span></div><div class='line' id='LC497'>					<span class="kr">if</span> <span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span> <span class="o">==</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC498'>					<span class="p">{</span></div><div class='line' id='LC499'>						<span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span> <span class="o">=</span> <span class="p">{};</span></div><div class='line' id='LC500'>					<span class="p">}</span></div><div class='line' id='LC501'>					<span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">mute</span> <span class="o">=</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">mute</span><span class="p">;</span></div><div class='line' id='LC502'>					<span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">volume</span> <span class="o">=</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">volume</span><span class="p">;</span></div><div class='line' id='LC503'>					<span class="n">soundPrefs</span><span class="o">.</span><span class="n">close</span><span class="p">();</span></div><div class='line' id='LC504'>				<span class="p">}</span></div><div class='line' id='LC505'>			<span class="p">}</span></div><div class='line' id='LC506'>		<span class="p">}</span></div><div class='line' id='LC507'>	<span class="p">}</span></div><div class='line' id='LC508'><br/></div><div class='line' id='LC509'>	<span class="cm">/**</span></div><div class='line' id='LC510'><span class="cm">	 * This function is called by step() and updates the actual game state.</span></div><div class='line' id='LC511'><span class="cm">	 * May be called multiple times per &quot;frame&quot; or draw call.</span></div><div class='line' id='LC512'><span class="cm">	 */</span></div><div class='line' id='LC513'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">update</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC514'>	<span class="p">{</span></div><div class='line' id='LC515'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_state</span> <span class="o">!=</span> <span class="n">_requestedState</span><span class="p">)</span></div><div class='line' id='LC516'>			<span class="n">switchState</span><span class="p">();</span></div><div class='line' id='LC517'><br/></div><div class='line' id='LC518'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC519'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC520'>			<span class="n">_mark</span> <span class="o">=</span> <span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">();</span> <span class="c1">// getTimer is expensive, only do it if necessary</span></div><div class='line' id='LC521'>		<span class="cp">#end</span></div><div class='line' id='LC522'><br/></div><div class='line' id='LC523'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">elapsed</span> <span class="o">=</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">timeScale</span> <span class="o">*</span> <span class="n">_stepSeconds</span><span class="p">;</span></div><div class='line' id='LC524'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">updateSounds</span><span class="p">();</span></div><div class='line' id='LC525'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">updatePlugins</span><span class="p">();</span></div><div class='line' id='LC526'><br/></div><div class='line' id='LC527'>		<span class="n">updateInput</span><span class="p">();</span></div><div class='line' id='LC528'>		<span class="n">updateState</span><span class="p">();</span></div><div class='line' id='LC529'><br/></div><div class='line' id='LC530'>		<span class="kr">if</span> <span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">tweener</span><span class="o">.</span><span class="n">active</span> <span class="o">&amp;&amp;</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">tweener</span><span class="o">.</span><span class="n">hasTween</span><span class="p">)</span> </div><div class='line' id='LC531'>		<span class="p">{</span></div><div class='line' id='LC532'>			<span class="n">FlxG</span><span class="o">.</span><span class="n">tweener</span><span class="o">.</span><span class="n">updateTweens</span><span class="p">();</span></div><div class='line' id='LC533'>		<span class="p">}</span></div><div class='line' id='LC534'><br/></div><div class='line' id='LC535'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">updateCameras</span><span class="p">();</span></div><div class='line' id='LC536'><br/></div><div class='line' id='LC537'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC538'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC539'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">flixelUpdate</span><span class="p">(</span><span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">()</span> <span class="o">-</span> <span class="n">_mark</span><span class="p">);</span></div><div class='line' id='LC540'>		<span class="cp">#end</span></div><div class='line' id='LC541'>	<span class="p">}</span></div><div class='line' id='LC542'><br/></div><div class='line' id='LC543'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">updateState</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC544'>	<span class="p">{</span></div><div class='line' id='LC545'>		<span class="n">_state</span><span class="o">.</span><span class="n">tryUpdate</span><span class="p">();</span></div><div class='line' id='LC546'>	<span class="p">}</span></div><div class='line' id='LC547'><br/></div><div class='line' id='LC548'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">updateInput</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC549'>	<span class="p">{</span></div><div class='line' id='LC550'>		<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC551'>		<span class="kr">if</span><span class="p">(</span><span class="n">_replaying</span><span class="p">)</span></div><div class='line' id='LC552'>		<span class="p">{</span></div><div class='line' id='LC553'>			<span class="n">_replay</span><span class="o">.</span><span class="n">playNextFrame</span><span class="p">();</span></div><div class='line' id='LC554'>			<span class="kr">if</span><span class="p">(</span><span class="n">_replayTimer</span> <span class="o">&gt;</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC555'>			<span class="p">{</span></div><div class='line' id='LC556'>				<span class="n">_replayTimer</span> <span class="o">-=</span> <span class="n">_step</span><span class="p">;</span></div><div class='line' id='LC557'>				<span class="kr">if</span><span class="p">(</span><span class="n">_replayTimer</span> <span class="o">&lt;=</span> <span class="mi">0</span><span class="p">)</span></div><div class='line' id='LC558'>				<span class="p">{</span></div><div class='line' id='LC559'>					<span class="kr">if</span><span class="p">(</span><span class="n">_replayCallback</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC560'>					<span class="p">{</span></div><div class='line' id='LC561'>						<span class="n">_replayCallback</span><span class="p">();</span></div><div class='line' id='LC562'>						<span class="n">_replayCallback</span> <span class="o">=</span> <span class="kc">null</span><span class="p">;</span></div><div class='line' id='LC563'>					<span class="p">}</span></div><div class='line' id='LC564'>					<span class="kr">else</span></div><div class='line' id='LC565'>					<span class="p">{</span></div><div class='line' id='LC566'>						<span class="n">FlxG</span><span class="o">.</span><span class="n">stopReplay</span><span class="p">();</span></div><div class='line' id='LC567'>					<span class="p">}</span></div><div class='line' id='LC568'>				<span class="p">}</span></div><div class='line' id='LC569'>			<span class="p">}</span></div><div class='line' id='LC570'>			<span class="kr">if</span><span class="p">(</span><span class="n">_replaying</span> <span class="o">&amp;&amp;</span> <span class="n">_replay</span><span class="o">.</span><span class="n">finished</span><span class="p">)</span></div><div class='line' id='LC571'>			<span class="p">{</span></div><div class='line' id='LC572'>				<span class="n">FlxG</span><span class="o">.</span><span class="n">stopReplay</span><span class="p">();</span></div><div class='line' id='LC573'>				<span class="kr">if</span><span class="p">(</span><span class="n">_replayCallback</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC574'>				<span class="p">{</span></div><div class='line' id='LC575'>					<span class="n">_replayCallback</span><span class="p">();</span></div><div class='line' id='LC576'>					<span class="n">_replayCallback</span> <span class="o">=</span> <span class="kc">null</span><span class="p">;</span></div><div class='line' id='LC577'>				<span class="p">}</span></div><div class='line' id='LC578'>			<span class="p">}</span></div><div class='line' id='LC579'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC580'>				<span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">updateRuntime</span><span class="p">(</span><span class="n">_step</span><span class="p">);</span></div><div class='line' id='LC581'>			<span class="cp">#end</span></div><div class='line' id='LC582'>		<span class="p">}</span></div><div class='line' id='LC583'>		<span class="kr">else</span></div><div class='line' id='LC584'>		<span class="p">{</span></div><div class='line' id='LC585'>		<span class="cp">#end</span></div><div class='line' id='LC586'><br/></div><div class='line' id='LC587'>		<span class="n">FlxInputs</span><span class="o">.</span><span class="n">updateInputs</span><span class="p">();</span></div><div class='line' id='LC588'><br/></div><div class='line' id='LC589'>		<span class="cp">#if !FLX_NO_RECORD</span></div><div class='line' id='LC590'>		<span class="p">}</span></div><div class='line' id='LC591'>		<span class="kr">if</span><span class="p">(</span><span class="n">_recording</span><span class="p">)</span></div><div class='line' id='LC592'>		<span class="p">{</span></div><div class='line' id='LC593'>			<span class="n">_replay</span><span class="o">.</span><span class="n">recordFrame</span><span class="p">();</span></div><div class='line' id='LC594'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC595'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">vcr</span><span class="o">.</span><span class="n">updateRuntime</span><span class="p">(</span><span class="n">_step</span><span class="p">);</span></div><div class='line' id='LC596'>			<span class="cp">#end</span></div><div class='line' id='LC597'>		<span class="p">}</span></div><div class='line' id='LC598'>		<span class="cp">#end</span></div><div class='line' id='LC599'><br/></div><div class='line' id='LC600'>		<span class="cp">#if !FLX_NO_MOUSE</span></div><div class='line' id='LC601'>		<span class="c1">//todo test why is this needed can it be put in FlxMouse</span></div><div class='line' id='LC602'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">mouse</span><span class="o">.</span><span class="n">wheel</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC603'>		<span class="cp">#end</span></div><div class='line' id='LC604'>	<span class="p">}</span></div><div class='line' id='LC605'><br/></div><div class='line' id='LC606'>	<span class="cm">/**</span></div><div class='line' id='LC607'><span class="cm">	 * Goes through the game state and draws all the game objects and special effects.</span></div><div class='line' id='LC608'><span class="cm">	 */</span></div><div class='line' id='LC609'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">draw</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC610'>	<span class="p">{</span></div><div class='line' id='LC611'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC612'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC613'>			<span class="n">_mark</span> <span class="o">=</span> <span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">();</span> <span class="c1">// getTimer is expensive, only do it if necessary</span></div><div class='line' id='LC614'>		<span class="cp">#end</span></div><div class='line' id='LC615'><br/></div><div class='line' id='LC616'>		<span class="cp">#if !flash</span></div><div class='line' id='LC617'>		<span class="n">TileSheetData</span><span class="o">.</span><span class="n">_DRAWCALLS</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC618'>		<span class="cp">#end</span></div><div class='line' id='LC619'><br/></div><div class='line' id='LC620'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">lockCameras</span><span class="p">();</span></div><div class='line' id='LC621'>		<span class="n">_state</span><span class="o">.</span><span class="n">draw</span><span class="p">();</span></div><div class='line' id='LC622'><br/></div><div class='line' id='LC623'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC624'>		<span class="kr">if</span> <span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">visualDebug</span><span class="p">)</span></div><div class='line' id='LC625'>		<span class="p">{</span></div><div class='line' id='LC626'>			<span class="n">_state</span><span class="o">.</span><span class="n">drawDebug</span><span class="p">();</span></div><div class='line' id='LC627'>		<span class="p">}</span></div><div class='line' id='LC628'>		<span class="cp">#end</span></div><div class='line' id='LC629'><br/></div><div class='line' id='LC630'>		<span class="cp">#if !flash</span></div><div class='line' id='LC631'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">renderCameras</span><span class="p">();</span></div><div class='line' id='LC632'><br/></div><div class='line' id='LC633'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC634'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC635'>		<span class="p">{</span></div><div class='line' id='LC636'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">drawCalls</span><span class="p">(</span><span class="n">TileSheetData</span><span class="o">.</span><span class="n">_DRAWCALLS</span><span class="p">);</span></div><div class='line' id='LC637'>		<span class="p">}</span></div><div class='line' id='LC638'>		<span class="cp">#end</span></div><div class='line' id='LC639'>		<span class="cp">#end</span></div><div class='line' id='LC640'><br/></div><div class='line' id='LC641'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">drawPlugins</span><span class="p">();</span></div><div class='line' id='LC642'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC643'>		<span class="kr">if</span> <span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">visualDebug</span><span class="p">)</span></div><div class='line' id='LC644'>		<span class="p">{</span></div><div class='line' id='LC645'>			<span class="n">FlxG</span><span class="o">.</span><span class="n">drawDebugPlugins</span><span class="p">();</span></div><div class='line' id='LC646'>		<span class="p">}</span></div><div class='line' id='LC647'>		<span class="cp">#end</span></div><div class='line' id='LC648'>		<span class="n">FlxG</span><span class="o">.</span><span class="n">unlockCameras</span><span class="p">();</span></div><div class='line' id='LC649'>		<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC650'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_debuggerUp</span><span class="p">)</span></div><div class='line' id='LC651'>			<span class="n">_debugger</span><span class="o">.</span><span class="n">perf</span><span class="o">.</span><span class="n">flixelDraw</span><span class="p">(</span><span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">()</span> <span class="o">-</span> <span class="n">_mark</span><span class="p">);</span></div><div class='line' id='LC652'>		<span class="cp">#end</span></div><div class='line' id='LC653'>	<span class="p">}</span></div><div class='line' id='LC654'><br/></div><div class='line' id='LC655'>	<span class="cm">/**</span></div><div class='line' id='LC656'><span class="cm">	 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.</span></div><div class='line' id='LC657'><span class="cm">	 * </span></div><div class='line' id='LC658'><span class="cm">	 * @param	FlashEvent	Just a Flash system event, not too important for our purposes.</span></div><div class='line' id='LC659'><span class="cm">	 */</span></div><div class='line' id='LC660'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">create</span><span class="p">(</span><span class="nv">FlashEvent</span><span class="p">:</span><span class="nc">Event</span><span class="p">):</span><span class="nc">Void</span></div><div class='line' id='LC661'>	<span class="p">{</span></div><div class='line' id='LC662'>		<span class="kr">if</span> <span class="p">(</span><span class="n">stage</span> <span class="o">==</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC663'>		<span class="p">{</span></div><div class='line' id='LC664'>			<span class="kr">return</span><span class="p">;</span></div><div class='line' id='LC665'>		<span class="p">}</span></div><div class='line' id='LC666'>		<span class="n">removeEventListener</span><span class="p">(</span><span class="n">Event</span><span class="o">.</span><span class="n">ADDED_TO_STAGE</span><span class="p">,</span> <span class="n">create</span><span class="p">);</span></div><div class='line' id='LC667'><br/></div><div class='line' id='LC668'>		<span class="n">_total</span> <span class="o">=</span> <span class="n">Lib</span><span class="o">.</span><span class="n">getTimer</span><span class="p">();</span></div><div class='line' id='LC669'>		<span class="c1">//Set up the view window and double buffering</span></div><div class='line' id='LC670'>		<span class="n">stage</span><span class="o">.</span><span class="n">scaleMode</span> <span class="o">=</span> <span class="n">StageScaleMode</span><span class="o">.</span><span class="n">NO_SCALE</span><span class="p">;</span></div><div class='line' id='LC671'>		<span class="n">stage</span><span class="o">.</span><span class="n">align</span> <span class="o">=</span> <span class="n">StageAlign</span><span class="o">.</span><span class="n">TOP_LEFT</span><span class="p">;</span></div><div class='line' id='LC672'>		<span class="n">stage</span><span class="o">.</span><span class="n">frameRate</span> <span class="o">=</span> <span class="n">_flashFramerate</span><span class="p">;</span></div><div class='line' id='LC673'><br/></div><div class='line' id='LC674'>		<span class="n">addChild</span><span class="p">(</span><span class="n">_inputContainer</span><span class="p">);</span></div><div class='line' id='LC675'><br/></div><div class='line' id='LC676'>		<span class="n">FlxInputs</span><span class="o">.</span><span class="n">init</span><span class="p">();</span></div><div class='line' id='LC677'><br/></div><div class='line' id='LC678'>		<span class="c1">//Let mobile devs opt out of unnecessary overlays.</span></div><div class='line' id='LC679'>		<span class="kr">if</span><span class="p">(</span><span class="o">!</span><span class="n">FlxG</span><span class="o">.</span><span class="n">mobile</span><span class="p">)</span></div><div class='line' id='LC680'>		<span class="p">{</span></div><div class='line' id='LC681'>			<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC682'>			<span class="c1">//Debugger overlay</span></div><div class='line' id='LC683'>			<span class="kr">if</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">debug</span><span class="p">)</span></div><div class='line' id='LC684'>			<span class="p">{</span></div><div class='line' id='LC685'>				<span class="n">_debugger</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">FlxDebugger</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">width</span> <span class="o">*</span> <span class="n">FlxCamera</span><span class="o">.</span><span class="n">defaultZoom</span><span class="p">,</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">height</span> <span class="o">*</span> <span class="n">FlxCamera</span><span class="o">.</span><span class="n">defaultZoom</span><span class="p">);</span></div><div class='line' id='LC686'>				<span class="cp">#if flash</span></div><div class='line' id='LC687'>				<span class="n">addChild</span><span class="p">(</span><span class="n">_debugger</span><span class="p">);</span></div><div class='line' id='LC688'>				<span class="cp">#else</span></div><div class='line' id='LC689'>				<span class="n">Lib</span><span class="o">.</span><span class="n">current</span><span class="o">.</span><span class="n">stage</span><span class="o">.</span><span class="n">addChild</span><span class="p">(</span><span class="n">_debugger</span><span class="p">);</span></div><div class='line' id='LC690'>				<span class="cp">#end</span></div><div class='line' id='LC691'>			<span class="p">}</span></div><div class='line' id='LC692'>			<span class="cp">#end</span></div><div class='line' id='LC693'><br/></div><div class='line' id='LC694'>			<span class="c1">//Volume display tab</span></div><div class='line' id='LC695'>			<span class="n">createSoundTray</span><span class="p">();</span></div><div class='line' id='LC696'><br/></div><div class='line' id='LC697'>			<span class="c1">//Focus gained/lost monitoring</span></div><div class='line' id='LC698'>			<span class="n">stage</span><span class="o">.</span><span class="n">addEventListener</span><span class="p">(</span><span class="n">Event</span><span class="o">.</span><span class="n">DEACTIVATE</span><span class="p">,</span> <span class="n">onFocusLost</span><span class="p">);</span></div><div class='line' id='LC699'>			<span class="n">stage</span><span class="o">.</span><span class="n">addEventListener</span><span class="p">(</span><span class="n">Event</span><span class="o">.</span><span class="n">ACTIVATE</span><span class="p">,</span> <span class="n">onFocus</span><span class="p">);</span></div><div class='line' id='LC700'>			<span class="c1">// TODO: add event listeners for Event.ACTIVATE/DEACTIVATE </span></div><div class='line' id='LC701'>			<span class="n">createFocusScreen</span><span class="p">();</span></div><div class='line' id='LC702'>		<span class="p">}</span></div><div class='line' id='LC703'><br/></div><div class='line' id='LC704'>		<span class="c1">// Instantiate the initial state</span></div><div class='line' id='LC705'>		<span class="kr">if</span> <span class="p">(</span><span class="n">_requestedReset</span><span class="p">)</span></div><div class='line' id='LC706'>		<span class="p">{</span></div><div class='line' id='LC707'>			<span class="n">resetGame</span><span class="p">();</span></div><div class='line' id='LC708'>			<span class="n">switchState</span><span class="p">();</span></div><div class='line' id='LC709'>			<span class="n">_requestedReset</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC710'>		<span class="p">}</span></div><div class='line' id='LC711'><br/></div><div class='line' id='LC712'>		<span class="cp">#if (cpp &amp;&amp; thread)</span></div><div class='line' id='LC713'>		<span class="n">threadSync</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">cpp.vm.Deque</span><span class="p">();</span></div><div class='line' id='LC714'>		<span class="n">cpp</span><span class="o">.</span><span class="n">vm</span><span class="o">.</span><span class="n">Thread</span><span class="o">.</span><span class="n">create</span><span class="p">(</span><span class="n">threadedUpdate</span><span class="p">);</span></div><div class='line' id='LC715'>		<span class="cp">#end</span></div><div class='line' id='LC716'><br/></div><div class='line' id='LC717'>		<span class="c1">//Finally, set up an event for the actual game loop stuff.</span></div><div class='line' id='LC718'>		<span class="n">Lib</span><span class="o">.</span><span class="n">current</span><span class="o">.</span><span class="n">stage</span><span class="o">.</span><span class="n">addEventListener</span><span class="p">(</span><span class="n">Event</span><span class="o">.</span><span class="n">ENTER_FRAME</span><span class="p">,</span> <span class="n">onEnterFrame</span><span class="p">);</span></div><div class='line' id='LC719'>	<span class="p">}</span></div><div class='line' id='LC720'><br/></div><div class='line' id='LC721'>	<span class="cm">/**</span></div><div class='line' id='LC722'><span class="cm">	 * Sets up the &quot;sound tray&quot;, the little volume meter that pops down sometimes.</span></div><div class='line' id='LC723'><span class="cm">	 */</span></div><div class='line' id='LC724'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">createSoundTray</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC725'>	<span class="p">{</span></div><div class='line' id='LC726'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC727'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">scaleX</span> <span class="o">=</span> <span class="mi">2</span><span class="p">;</span></div><div class='line' id='LC728'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">scaleY</span> <span class="o">=</span> <span class="mi">2</span><span class="p">;</span></div><div class='line' id='LC729'>		<span class="cp">#if !neko</span></div><div class='line' id='LC730'>		<span class="kd">var</span> <span class="nv">tmp</span><span class="p">:</span><span class="nc">Bitmap</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Bitmap</span><span class="p">(</span><span class="k">new</span> <span class="nc">BitmapData</span><span class="p">(</span><span class="mi">80</span><span class="p">,</span> <span class="mi">30</span><span class="p">,</span> <span class="kc">true</span><span class="p">,</span> <span class="mh">0x7F000000</span><span class="p">));</span></div><div class='line' id='LC731'>		<span class="cp">#else</span></div><div class='line' id='LC732'>		<span class="kd">var</span> <span class="nv">tmp</span><span class="p">:</span><span class="nc">Bitmap</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Bitmap</span><span class="p">(</span><span class="k">new</span> <span class="nc">BitmapData</span><span class="p">(</span><span class="mi">80</span><span class="p">,</span> <span class="mi">30</span><span class="p">,</span> <span class="kc">true</span><span class="p">,</span> <span class="p">{</span><span class="n">rgb</span><span class="o">:</span> <span class="mh">0x000000</span><span class="p">,</span> <span class="n">a</span><span class="o">:</span> <span class="mh">0x7F</span><span class="p">}));</span></div><div class='line' id='LC733'>		<span class="cp">#end</span></div><div class='line' id='LC734'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">x</span> <span class="o">=</span> <span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">width</span> <span class="o">/</span> <span class="mi">2</span><span class="p">)</span> <span class="o">*</span> <span class="n">FlxCamera</span><span class="o">.</span><span class="n">defaultZoom</span> <span class="o">-</span> <span class="p">(</span><span class="n">tmp</span><span class="o">.</span><span class="n">width</span> <span class="o">/</span> <span class="mi">2</span><span class="p">)</span> <span class="o">*</span> <span class="n">_soundTray</span><span class="o">.</span><span class="n">scaleX</span><span class="p">;</span></div><div class='line' id='LC735'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">addChild</span><span class="p">(</span><span class="n">tmp</span><span class="p">);</span></div><div class='line' id='LC736'><br/></div><div class='line' id='LC737'>		<span class="kd">var</span> <span class="nv">text</span><span class="p">:</span><span class="nc">TextField</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">TextField</span><span class="p">();</span></div><div class='line' id='LC738'>		<span class="n">text</span><span class="o">.</span><span class="n">width</span> <span class="o">=</span> <span class="n">tmp</span><span class="o">.</span><span class="n">width</span><span class="p">;</span></div><div class='line' id='LC739'>		<span class="n">text</span><span class="o">.</span><span class="n">height</span> <span class="o">=</span> <span class="n">tmp</span><span class="o">.</span><span class="n">height</span><span class="p">;</span></div><div class='line' id='LC740'>		<span class="n">text</span><span class="o">.</span><span class="n">multiline</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC741'>		<span class="n">text</span><span class="o">.</span><span class="n">wordWrap</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC742'>		<span class="n">text</span><span class="o">.</span><span class="n">selectable</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC743'>		<span class="cp">#if flash</span></div><div class='line' id='LC744'>		<span class="n">text</span><span class="o">.</span><span class="n">embedFonts</span> <span class="o">=</span> <span class="kc">true</span><span class="p">;</span></div><div class='line' id='LC745'>		<span class="n">text</span><span class="o">.</span><span class="n">antiAliasType</span> <span class="o">=</span> <span class="n">AntiAliasType</span><span class="o">.</span><span class="n">NORMAL</span><span class="p">;</span></div><div class='line' id='LC746'>		<span class="n">text</span><span class="o">.</span><span class="n">gridFitType</span> <span class="o">=</span> <span class="n">GridFitType</span><span class="o">.</span><span class="n">PIXEL</span><span class="p">;</span></div><div class='line' id='LC747'>		<span class="cp">#else</span></div><div class='line' id='LC748'><br/></div><div class='line' id='LC749'>		<span class="cp">#end</span></div><div class='line' id='LC750'>		<span class="kd">var</span> <span class="nv">dtf</span><span class="p">:</span><span class="nc">TextFormat</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">TextFormat</span><span class="p">(</span><span class="n">Assets</span><span class="o">.</span><span class="n">getFont</span><span class="p">(</span><span class="n">FlxAssets</span><span class="o">.</span><span class="n">defaultFont</span><span class="p">)</span><span class="o">.</span><span class="n">fontName</span><span class="p">,</span> <span class="mi">8</span><span class="p">,</span> <span class="mh">0xffffff</span><span class="p">);</span></div><div class='line' id='LC751'>		<span class="n">dtf</span><span class="o">.</span><span class="n">align</span> <span class="o">=</span> <span class="n">TextFormatAlign</span><span class="o">.</span><span class="n">CENTER</span><span class="p">;</span></div><div class='line' id='LC752'>		<span class="n">text</span><span class="o">.</span><span class="n">defaultTextFormat</span> <span class="o">=</span> <span class="n">dtf</span><span class="p">;</span></div><div class='line' id='LC753'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">addChild</span><span class="p">(</span><span class="n">text</span><span class="p">);</span></div><div class='line' id='LC754'>		<span class="n">text</span><span class="o">.</span><span class="n">text</span> <span class="o">=</span> <span class="s2">&quot;VOLUME&quot;</span><span class="p">;</span></div><div class='line' id='LC755'>		<span class="n">text</span><span class="o">.</span><span class="n">y</span> <span class="o">=</span> <span class="mi">16</span><span class="p">;</span></div><div class='line' id='LC756'><br/></div><div class='line' id='LC757'>		<span class="kd">var</span> <span class="nv">bx</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="mi">10</span><span class="p">;</span></div><div class='line' id='LC758'>		<span class="kd">var</span> <span class="nv">by</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="mi">14</span><span class="p">;</span></div><div class='line' id='LC759'>		<span class="n">_soundTrayBars</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Array</span><span class="p">();</span></div><div class='line' id='LC760'>		<span class="kd">var</span> <span class="nv">i</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="mi">0</span><span class="p">;</span></div><div class='line' id='LC761'>		<span class="kr">while</span><span class="p">(</span><span class="n">i</span> <span class="o">&lt;</span> <span class="mi">10</span><span class="p">)</span></div><div class='line' id='LC762'>		<span class="p">{</span></div><div class='line' id='LC763'>			<span class="n">tmp</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Bitmap</span><span class="p">(</span><span class="k">new</span> <span class="nc">BitmapData</span><span class="p">(</span><span class="mi">4</span><span class="p">,</span> <span class="o">++</span><span class="n">i</span><span class="p">,</span> <span class="kc">false</span><span class="p">,</span> <span class="n">FlxG</span><span class="o">.</span><span class="n">WHITE</span><span class="p">));</span></div><div class='line' id='LC764'>			<span class="n">tmp</span><span class="o">.</span><span class="n">x</span> <span class="o">=</span> <span class="n">bx</span><span class="p">;</span></div><div class='line' id='LC765'>			<span class="n">tmp</span><span class="o">.</span><span class="n">y</span> <span class="o">=</span> <span class="n">by</span><span class="p">;</span></div><div class='line' id='LC766'>			<span class="n">_soundTray</span><span class="o">.</span><span class="n">addChild</span><span class="p">(</span><span class="n">tmp</span><span class="p">);</span></div><div class='line' id='LC767'>			<span class="n">_soundTrayBars</span><span class="o">.</span><span class="n">push</span><span class="p">(</span><span class="n">tmp</span><span class="p">);</span></div><div class='line' id='LC768'>			<span class="n">bx</span> <span class="o">+=</span> <span class="mi">6</span><span class="p">;</span></div><div class='line' id='LC769'>			<span class="n">by</span><span class="o">--</span><span class="p">;</span></div><div class='line' id='LC770'>		<span class="p">}</span></div><div class='line' id='LC771'><br/></div><div class='line' id='LC772'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">y</span> <span class="o">=</span> <span class="o">-</span><span class="n">_soundTray</span><span class="o">.</span><span class="n">height</span><span class="p">;</span></div><div class='line' id='LC773'>		<span class="n">_soundTray</span><span class="o">.</span><span class="n">visible</span> <span class="o">=</span> <span class="kc">false</span><span class="p">;</span></div><div class='line' id='LC774'>		<span class="n">addChild</span><span class="p">(</span><span class="n">_soundTray</span><span class="p">);</span></div><div class='line' id='LC775'><br/></div><div class='line' id='LC776'>		<span class="c1">//load saved sound preferences for this game if they exist</span></div><div class='line' id='LC777'>		<span class="kd">var</span> <span class="nv">soundPrefs</span><span class="p">:</span><span class="nc">FlxSave</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">FlxSave</span><span class="p">();</span></div><div class='line' id='LC778'>		<span class="kr">if</span><span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">bind</span><span class="p">(</span><span class="s2">&quot;flixel&quot;</span><span class="p">)</span> <span class="o">&amp;&amp;</span> <span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">))</span></div><div class='line' id='LC779'>		<span class="p">{</span></div><div class='line' id='LC780'>			<span class="kr">if</span> <span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">volume</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC781'>			<span class="p">{</span></div><div class='line' id='LC782'>				<span class="n">FlxG</span><span class="o">.</span><span class="n">volume</span> <span class="o">=</span> <span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">volume</span><span class="p">;</span></div><div class='line' id='LC783'>			<span class="p">}</span></div><div class='line' id='LC784'>			<span class="kr">if</span> <span class="p">(</span><span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">mute</span> <span class="o">!=</span> <span class="kc">null</span><span class="p">)</span></div><div class='line' id='LC785'>			<span class="p">{</span></div><div class='line' id='LC786'>				<span class="n">FlxG</span><span class="o">.</span><span class="n">mute</span> <span class="o">=</span> <span class="n">soundPrefs</span><span class="o">.</span><span class="n">data</span><span class="o">.</span><span class="n">sound</span><span class="o">.</span><span class="n">mute</span><span class="p">;</span></div><div class='line' id='LC787'>			<span class="p">}</span></div><div class='line' id='LC788'>			<span class="n">soundPrefs</span><span class="o">.</span><span class="n">destroy</span><span class="p">();</span></div><div class='line' id='LC789'>		<span class="p">}</span></div><div class='line' id='LC790'>	<span class="p">}</span></div><div class='line' id='LC791'><br/></div><div class='line' id='LC792'>	<span class="cm">/**</span></div><div class='line' id='LC793'><span class="cm">	 * Sets up the darkened overlay with the big white &quot;play&quot; button that appears when a flixel game loses focus.</span></div><div class='line' id='LC794'><span class="cm">	 */</span></div><div class='line' id='LC795'>	<span class="kd">private</span> <span class="kd">function</span> <span class="nf">createFocusScreen</span><span class="p">():</span><span class="nc">Void</span></div><div class='line' id='LC796'>	<span class="p">{</span></div><div class='line' id='LC797'>		<span class="kd">var</span> <span class="nv">gfx</span><span class="p">:</span><span class="nc">Graphics</span> <span class="o">=</span> <span class="n">_focus</span><span class="o">.</span><span class="n">graphics</span><span class="p">;</span></div><div class='line' id='LC798'>		<span class="kd">var</span> <span class="nv">screenWidth</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Std</span><span class="o">.</span><span class="n">int</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">width</span> <span class="o">*</span> <span class="n">FlxCamera</span><span class="o">.</span><span class="n">defaultZoom</span><span class="p">);</span></div><div class='line' id='LC799'>		<span class="kd">var</span> <span class="nv">screenHeight</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Std</span><span class="o">.</span><span class="n">int</span><span class="p">(</span><span class="n">FlxG</span><span class="o">.</span><span class="n">height</span> <span class="o">*</span> <span class="n">FlxCamera</span><span class="o">.</span><span class="n">defaultZoom</span><span class="p">);</span></div><div class='line' id='LC800'><br/></div><div class='line' id='LC801'>		<span class="c1">//draw transparent black backdrop</span></div><div class='line' id='LC802'>		<span class="n">gfx</span><span class="o">.</span><span class="n">moveTo</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">);</span></div><div class='line' id='LC803'>		<span class="n">gfx</span><span class="o">.</span><span class="n">beginFill</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="o">.</span><span class="mi">5</span><span class="p">);</span></div><div class='line' id='LC804'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="n">screenWidth</span><span class="p">,</span> <span class="mi">0</span><span class="p">);</span></div><div class='line' id='LC805'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="n">screenWidth</span><span class="p">,</span> <span class="n">screenHeight</span><span class="p">);</span></div><div class='line' id='LC806'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="n">screenHeight</span><span class="p">);</span></div><div class='line' id='LC807'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="mi">0</span><span class="p">,</span> <span class="mi">0</span><span class="p">);</span></div><div class='line' id='LC808'>		<span class="n">gfx</span><span class="o">.</span><span class="n">endFill</span><span class="p">();</span></div><div class='line' id='LC809'><br/></div><div class='line' id='LC810'>		<span class="c1">//draw white arrow</span></div><div class='line' id='LC811'>		<span class="kd">var</span> <span class="nv">halfWidth</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Std</span><span class="o">.</span><span class="n">int</span><span class="p">(</span><span class="n">screenWidth</span> <span class="o">/</span> <span class="mi">2</span><span class="p">);</span></div><div class='line' id='LC812'>		<span class="kd">var</span> <span class="nv">halfHeight</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Std</span><span class="o">.</span><span class="n">int</span><span class="p">(</span><span class="n">screenHeight</span> <span class="o">/</span> <span class="mi">2</span><span class="p">);</span></div><div class='line' id='LC813'>		<span class="kd">var</span> <span class="nv">helper</span><span class="p">:</span><span class="nc">Int</span> <span class="o">=</span> <span class="n">Std</span><span class="o">.</span><span class="n">int</span><span class="p">(</span><span class="n">FlxU</span><span class="o">.</span><span class="n">min</span><span class="p">(</span><span class="n">halfWidth</span><span class="p">,</span> <span class="n">halfHeight</span><span class="p">)</span> <span class="o">/</span> <span class="mi">3</span><span class="p">);</span></div><div class='line' id='LC814'>		<span class="n">gfx</span><span class="o">.</span><span class="n">moveTo</span><span class="p">(</span><span class="n">halfWidth</span> <span class="o">-</span> <span class="n">helper</span><span class="p">,</span> <span class="n">halfHeight</span> <span class="o">-</span> <span class="n">helper</span><span class="p">);</span></div><div class='line' id='LC815'>		<span class="n">gfx</span><span class="o">.</span><span class="n">beginFill</span><span class="p">(</span><span class="mh">0xffffff</span><span class="p">,</span> <span class="mi">0</span><span class="o">.</span><span class="mi">65</span><span class="p">);</span></div><div class='line' id='LC816'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="n">halfWidth</span> <span class="o">+</span> <span class="n">helper</span><span class="p">,</span> <span class="n">halfHeight</span><span class="p">);</span></div><div class='line' id='LC817'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="n">halfWidth</span> <span class="o">-</span> <span class="n">helper</span><span class="p">,</span> <span class="n">halfHeight</span> <span class="o">+</span> <span class="n">helper</span><span class="p">);</span></div><div class='line' id='LC818'>		<span class="n">gfx</span><span class="o">.</span><span class="n">lineTo</span><span class="p">(</span><span class="n">halfWidth</span> <span class="o">-</span> <span class="n">helper</span><span class="p">,</span> <span class="n">halfHeight</span> <span class="o">-</span> <span class="n">helper</span><span class="p">);</span></div><div class='line' id='LC819'>		<span class="n">gfx</span><span class="o">.</span><span class="n">endFill</span><span class="p">();</span></div><div class='line' id='LC820'><br/></div><div class='line' id='LC821'>		<span class="kd">var</span> <span class="nv">logo</span><span class="p">:</span><span class="nc">Sprite</span> <span class="o">=</span> <span class="k">new</span> <span class="nc">Sprite</span><span class="p">();</span></div><div class='line' id='LC822'>		<span class="n">FlxAssets</span><span class="o">.</span><span class="n">drawLogo</span><span class="p">(</span><span class="n">logo</span><span class="o">.</span><span class="n">graphics</span><span class="p">);</span></div><div class='line' id='LC823'>		<span class="n">logo</span><span class="o">.</span><span class="n">scaleX</span> <span class="o">=</span> <span class="n">helper</span> <span class="o">/</span> <span class="mi">1000</span><span class="p">;</span></div><div class='line' id='LC824'>		<span class="kr">if</span> <span class="p">(</span><span class="n">logo</span><span class="o">.</span><span class="n">scaleX</span> <span class="o">&lt;</span> <span class="mi">0</span><span class="o">.</span><span class="mi">2</span><span class="p">)</span></div><div class='line' id='LC825'>		<span class="p">{</span></div><div class='line' id='LC826'>			<span class="n">logo</span><span class="o">.</span><span class="n">scaleX</span> <span class="o">=</span> <span class="mi">0</span><span class="o">.</span><span class="mi">2</span><span class="p">;</span></div><div class='line' id='LC827'>		<span class="p">}</span></div><div class='line' id='LC828'>		<span class="n">logo</span><span class="o">.</span><span class="n">scaleY</span> <span class="o">=</span> <span class="n">logo</span><span class="o">.</span><span class="n">scaleX</span><span class="p">;</span></div><div class='line' id='LC829'>		<span class="n">logo</span><span class="o">.</span><span class="n">x</span> <span class="o">=</span> <span class="n">logo</span><span class="o">.</span><span class="n">y</span> <span class="o">=</span> <span class="mi">5</span><span class="p">;</span></div><div class='line' id='LC830'>		<span class="n">logo</span><span class="o">.</span><span class="n">alpha</span> <span class="o">=</span> <span class="mi">0</span><span class="o">.</span><span class="mi">35</span><span class="p">;</span></div><div class='line' id='LC831'>		<span class="n">_focus</span><span class="o">.</span><span class="n">addChild</span><span class="p">(</span><span class="n">logo</span><span class="p">);</span></div><div class='line' id='LC832'><br/></div><div class='line' id='LC833'>		<span class="n">addChild</span><span class="p">(</span><span class="n">_focus</span><span class="p">);</span></div><div class='line' id='LC834'>	<span class="p">}</span></div><div class='line' id='LC835'><br/></div><div class='line' id='LC836'>	<span class="cp">#if !FLX_NO_DEBUG</span></div><div class='line' id='LC837'>	<span class="kd">public</span> <span class="kd">var</span> <span class="vi">debugger</span><span class="err">(get_debugger,</span> <span class="err">null)</span><span class="p">:</span><span class="nc">FlxDebugger</span><span class="p">;</span></div><div class='line' id='LC838'>	<span class="kd">public</span> <span class="kd">function</span> <span class="nf">get_debugger</span><span class="p">():</span><span class="nc">FlxDebugger</span></div><div class='line' id='LC839'>	<span class="p">{</span></div><div class='line' id='LC840'>		<span class="kr">return</span> <span class="n">_debugger</span><span class="p">;</span></div><div class='line' id='LC841'>	<span class="p">}</span></div><div class='line' id='LC842'>	<span class="cp">#end</span></div><div class='line' id='LC843'><span class="p">}</span></div></pre></div>
          </td>
        </tr>
      </table>
  </div>

          </div>
        </div>

        <a href="#jump-to-line" rel="facebox" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
        <div id="jump-to-line" style="display:none">
          <h2>Jump to Line</h2>
          <form accept-charset="UTF-8" class="js-jump-to-line-form">
            <input class="textfield js-jump-to-line-field" type="text">
            <div class="full-button">
              <button type="submit" class="button">Go</button>
            </div>
          </form>
        </div>

      </div>
    </div>
</div>

<div id="js-frame-loading-template" class="frame frame-loading large-loading-area" style="display:none;">
  <img class="js-frame-loading-spinner" src="https://a248.e.akamai.net/assets.github.com/images/spinners/octocat-spinner-128.gif?1360648843" height="64" width="64">
</div>


        </div>
      </div>
      <div class="modal-backdrop"></div>
    </div>

      <div id="footer-push"></div><!-- hack for sticky footer -->
    </div><!-- end of wrapper - hack for sticky footer -->

      <!-- footer -->
      <div id="footer">
  <div class="container clearfix">

      <dl class="footer_nav">
        <dt>GitHub</dt>
        <dd><a href="https://github.com/about">About us</a></dd>
        <dd><a href="https://github.com/blog">Blog</a></dd>
        <dd><a href="https://github.com/contact">Contact &amp; support</a></dd>
        <dd><a href="http://enterprise.github.com/">GitHub Enterprise</a></dd>
        <dd><a href="http://status.github.com/">Site status</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Applications</dt>
        <dd><a href="http://mac.github.com/">GitHub for Mac</a></dd>
        <dd><a href="http://windows.github.com/">GitHub for Windows</a></dd>
        <dd><a href="http://eclipse.github.com/">GitHub for Eclipse</a></dd>
        <dd><a href="http://mobile.github.com/">GitHub mobile apps</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Services</dt>
        <dd><a href="http://get.gaug.es/">Gauges: Web analytics</a></dd>
        <dd><a href="http://speakerdeck.com">Speaker Deck: Presentations</a></dd>
        <dd><a href="https://gist.github.com">Gist: Code snippets</a></dd>
        <dd><a href="http://jobs.github.com/">Job board</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>Documentation</dt>
        <dd><a href="http://help.github.com/">GitHub Help</a></dd>
        <dd><a href="http://developer.github.com/">Developer API</a></dd>
        <dd><a href="http://github.github.com/github-flavored-markdown/">GitHub Flavored Markdown</a></dd>
        <dd><a href="http://pages.github.com/">GitHub Pages</a></dd>
      </dl>

      <dl class="footer_nav">
        <dt>More</dt>
        <dd><a href="http://training.github.com/">Training</a></dd>
        <dd><a href="https://github.com/edu">Students &amp; teachers</a></dd>
        <dd><a href="http://shop.github.com">The Shop</a></dd>
        <dd><a href="/plans">Plans &amp; pricing</a></dd>
        <dd><a href="http://octodex.github.com/">The Octodex</a></dd>
      </dl>

      <hr class="footer-divider">


    <p class="right">&copy; 2013 <span title="0.18749s from fe3.rs.github.com">GitHub</span>, Inc. All rights reserved.</p>
    <a class="left" href="https://github.com/">
      <span class="mega-icon mega-icon-invertocat"></span>
    </a>
    <ul id="legal">
        <li><a href="https://github.com/site/terms">Terms of Service</a></li>
        <li><a href="https://github.com/site/privacy">Privacy</a></li>
        <li><a href="https://github.com/security">Security</a></li>
    </ul>

  </div><!-- /.container -->

</div><!-- /.#footer -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/Beeblerox/HaxeFlixel/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-icon mega-icon-normalscreen"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="mini-icon mini-icon-brightness"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="mini-icon mini-icon-exclamation"></span>
      Something went wrong with that request. Please try again.
      <a href="#" class="mini-icon mini-icon-remove-close ajax-error-dismiss"></a>
    </div>

    
    
    <span id='server_response_time' data-time='0.18808' data-host='fe3'></span>
    
  </body>
</html>

