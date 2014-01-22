package com.liferay.portlet.journal.lar;

import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.lar.PortletDataContext;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.xml.Document;
import com.liferay.portal.kernel.xml.Element;
import com.liferay.portal.kernel.xml.SAXReaderUtil;
import com.liferay.portlet.journal.model.JournalArticle;
import com.liferay.portlet.journal.model.JournalFeed;
import com.liferay.portlet.journal.model.JournalStructure;
import com.liferay.portlet.journal.model.JournalTemplate;
import com.liferay.portlet.journal.service.persistence.JournalArticleUtil;
import com.liferay.portlet.journal.service.persistence.JournalFeedUtil;
import com.liferay.portlet.journal.service.persistence.JournalStructureUtil;
import com.liferay.portlet.journal.service.persistence.JournalTemplateUtil;
import com.liferay.portlet.journal.util.comparator.ArticleIDComparator;
import com.liferay.portlet.journal.util.comparator.StructurePKComparator;

import java.util.List;

import javax.portlet.PortletPreferences;

public class C0deSutraJournalPortletDataHandlerImpl extends JournalPortletDataHandlerImpl {
	
	private static final Log _log = LogFactoryUtil.getLog(C0deSutraJournalPortletDataHandlerImpl.class);
	
	private static final String _NAMESPACE = "journal";
	
	@Override
	protected String doExportData(PortletDataContext portletDataContext, String portletId, PortletPreferences portletPreferences) throws Exception {
		_log.info("C0deSutraJournalPortletDataHandlerImpl.doExportData() called");
		portletDataContext.addPermissions(
			"com.liferay.portlet.journal",
			portletDataContext.getScopeGroupId());

		Document document = SAXReaderUtil.createDocument();

		Element rootElement = document.addElement("journal-data");

		rootElement.addAttribute(
			"group-id", String.valueOf(portletDataContext.getScopeGroupId()));

		Element structuresElement = rootElement.addElement("structures");

		List<JournalStructure> structures = JournalStructureUtil.findByGroupId(
			portletDataContext.getScopeGroupId(), QueryUtil.ALL_POS,
			QueryUtil.ALL_POS, new StructurePKComparator(true));

		for (JournalStructure structure : structures) {
			if (portletDataContext.isWithinDateRange(
					structure.getModifiedDate())) {

				exportStructure(
					portletDataContext, structuresElement, structure);
			}
		}

		Element templatesElement = rootElement.addElement("templates");
		Element dlFoldersElement = rootElement.addElement("dl-folders");
		Element dlFilesElement = rootElement.addElement("dl-file-entries");
		Element dlFileRanksElement = rootElement.addElement("dl-file-ranks");
		Element igFoldersElement = rootElement.addElement("ig-folders");
		Element igImagesElement = rootElement.addElement("ig-images");

		List<JournalTemplate> templates = JournalTemplateUtil.findByGroupId(
			portletDataContext.getScopeGroupId());

		for (JournalTemplate template : templates) {
			if (portletDataContext.isWithinDateRange(
					template.getModifiedDate())) {

				exportTemplate(
					portletDataContext, templatesElement, dlFoldersElement,
					dlFilesElement, dlFileRanksElement, igFoldersElement,
					igImagesElement, template, true);
			}
		}

		Element feedsElement = rootElement.addElement("feeds");

		List<JournalFeed> feeds = JournalFeedUtil.findByGroupId(
			portletDataContext.getScopeGroupId());

		for (JournalFeed feed : feeds) {
			if (portletDataContext.isWithinDateRange(feed.getModifiedDate())) {
				exportFeed(portletDataContext, feedsElement, feed);
			}
		}

		Element articlesElement = rootElement.addElement("articles");

		if (portletDataContext.getBooleanParameter(_NAMESPACE, "articles")) {
			List<JournalArticle> articles = JournalArticleUtil.findByGroupId(
				portletDataContext.getScopeGroupId(), QueryUtil.ALL_POS,
				QueryUtil.ALL_POS, new ArticleIDComparator(true));
			
			
			boolean publishMyArticle = false;
			String publishMyArticleId = null; 
			if (portletDataContext.getParameterMap().containsKey("publish-my-article-id")) {
				_log.debug(">>>>>>>>> got article id = ");
				publishMyArticleId = portletDataContext.getParameterMap().get("publish-my-article-id")[0];
				_log.debug(">>>>>>>>> " + publishMyArticleId);
				publishMyArticle = true;
			}
			
			if (publishMyArticle && null != publishMyArticleId) {
				for (JournalArticle article : articles) {
					if (publishMyArticleId.equals(article.getArticleId())) {
						_log.debug(">>>>>>>>> publishing with articledId = "+article.getArticleId());
						exportArticle(
							portletDataContext, articlesElement, structuresElement,
							templatesElement, dlFoldersElement, dlFilesElement,
							dlFileRanksElement, igFoldersElement, igImagesElement,
							article, true);
					}
				}	
			} else {			
				for (JournalArticle article : articles) {
					
					exportArticle(
						portletDataContext, articlesElement, structuresElement,
						templatesElement, dlFoldersElement, dlFilesElement,
						dlFileRanksElement, igFoldersElement, igImagesElement,
						article, true);
				}
			}
		}

		return document.formattedString();
	}
}
