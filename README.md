publish-my-article
==================

To learn what this plugins does: http://www.coolc0de.com/2012/07/liferay-publish-article-by-article-id.html

How to deploy ext
==================
Clone the https://github.com/advaittrivedi/publish-my-article/tree/master/ext/publish-my-article-portal-ext in parent "ext" folder of Liferay plugins-sdk.

CD to publish-my-article-portal-ext and run standard Liferay deploy ant commands.
For convenience only, Ant build scripts are included with source code. 
There are plans to remove them from source code so that the code base is that much easier to upgrade to new Liferay versions.

How to deploy hook
==================
Clone https://github.com/advaittrivedi/publish-my-article/tree/master/hooks/publish-my-article-hook. Copy publish-my-article-hook to "hooks" folder of Liferay plugins-sdk.

CD to publish-my-article-hook and run standard Liferay deploy ant commands. And build.xml is provided which will be later removed.
