<%--
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * The contents of this file are subject to the terms of the Liferay Enterprise
 * Subscription License ("License"). You may not use this file except in
 * compliance with the License. You can obtain a copy of the License by
 * contacting Liferay, Inc. See the License for the specific language governing
 * permissions and limitations under the License, including but not limited to
 * distribution rights of the Software.
 *
 *
 *
 */
--%>

<%@ include file="/html/portlet/portlet_configuration/init.jsp" %>

<%
String tabs2 = ParamUtil.getString(request, "tabs2", "export");

String redirect = ParamUtil.getString(request, "redirect");
String returnToFullPageURL = ParamUtil.getString(request, "returnToFullPageURL");

String selPortletPrimaryKey = PortletPermissionUtil.getPrimaryKey(layout.getPlid(), selPortlet.getPortletId());

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/portlet_configuration/export_import");
portletURL.setParameter("redirect", redirect);
portletURL.setParameter("returnToFullPageURL", returnToFullPageURL);
portletURL.setParameter("portletResource", portletResource);

boolean supportsLAR = Validator.isNotNull(selPortlet.getPortletDataHandlerClass());

boolean supportsSetup = Validator.isNotNull(selPortlet.getConfigurationActionClass());

boolean controlPanel = false;

if (layout.isTypeControlPanel()) {
	Group scopeGroup = themeDisplay.getScopeGroup();

	if (scopeGroup.isLayout()) {
		layout = LayoutLocalServiceUtil.getLayout(scopeGroup.getClassPK());
	}
	else if (!scopeGroup.isCompany()) {
		long defaultPlid = LayoutLocalServiceUtil.getDefaultPlid(scopeGroupId);

		if (defaultPlid > 0) {
			layout = LayoutLocalServiceUtil.getLayout(defaultPlid);
		}
	}

	supportsSetup = false;

	controlPanel = true;
}
%>

<c:choose>
	<c:when test="<%= supportsLAR || supportsSetup %>">

		<%
		String tabs2Names = "export,import";

		Group scopeGroup = themeDisplay.getScopeGroup();

		if (scopeGroup.isStagingGroup()) {
			tabs2Names += ",staging";
		}
		else if (scopeGroup.isLayout()) {
			Group parentScopeGroup = GroupServiceUtil.getGroup(scopeGroup.getParentGroupId());

			if (parentScopeGroup.isStagingGroup()) {
				tabs2Names += ",staging";
			}
		}
		%>

		<liferay-ui:tabs
			names="<%= tabs2Names %>"
			param="tabs2"
			url="<%= portletURL.toString() %>"
			backURL="<%= redirect %>"
		/>

		<liferay-ui:error exception="<%= LARFileException.class %>" message="please-specify-a-lar-file-to-import" />
		<liferay-ui:error exception="<%= LARTypeException.class %>" message="please-import-a-lar-file-of-the-correct-type" />
		<liferay-ui:error exception="<%= LayoutImportException.class %>" message="an-unexpected-error-occurred-while-importing-your-file" />
		<liferay-ui:error exception="<%= NoSuchLayoutException.class %>" message="an-error-occurred-because-the-live-group-does-not-have-the-current-page" />
		<liferay-ui:error exception="<%= PortletIdException.class %>" message="please-import-a-lar-file-for-the-current-portlet" />

		<portlet:actionURL var="exportImportPagesURL">
			<portlet:param name="struts_action" value="/portlet_configuration/export_import" />
		</portlet:actionURL>

		<aui:form action="<%= exportImportPagesURL %>" method="post" name="fm">
			<aui:input name="tabs1" type="hidden" value="export_import" />
			<aui:input name="tabs2" type="hidden" value="<%= tabs2 %>" />
			<aui:input name="<%= Constants.CMD %>" type="hidden" />
			<aui:input name="plid" type="hidden" value="<%= layout.getPlid() %>" />
			<aui:input name="groupId" type="hidden" value="<%= themeDisplay.getScopeGroupId() %>" />
			<aui:input name="portletResource" type="hidden" value="<%= portletResource %>" />
			<aui:input name="redirect" type="hidden" value="<%= currentURL %>" />
			<aui:input name="publish-my-article-id" type="text"/>
			
			<c:choose>
				<c:when test='<%= tabs2.equals("export") %>'>
				<aui:fieldset>
					<aui:input label="export-the-selected-data-to-the-given-lar-file-name" name="exportFileName" size="50" value='<%= StringUtil.replace(selPortlet.getDisplayName(), " ", "_") + "-" + Time.getShortTimestamp() + ".portlet.lar" %>' />

					<aui:field-wrapper label="what-would-you-like-to-export">
						<%@ include file="/html/portlet/portlet_configuration/export_import_options.jspf" %>
					</aui:field-wrapper>

					<aui:button-row>
						<aui:button onClick='<%= renderResponse.getNamespace() + "exportData();" %>' value="export" />

						<aui:button href="<%= redirect %>" type="cancel" />
					</aui:button-row>
				</aui:fieldset>
				</c:when>
				<c:when test='<%= tabs2.equals("import") %>'>
					<aui:fieldset>
						<aui:input label="import-a-lar-file-to-overwrite-the-selected-data" name="importFileName" size="50" type="file" />

						<aui:field-wrapper label="what-would-you-like-to-import">
							<%@ include file="/html/portlet/portlet_configuration/export_import_options.jspf" %>
						</aui:field-wrapper>

						<aui:button-row>
							<aui:button onClick='<%= renderResponse.getNamespace() + "importData();" %>' value="import" />

							<aui:button href="<%= redirect %>" type="cancel" />
						</aui:button-row>
					</aui:fieldset>
				</c:when>
				<c:when test='<%= tabs2.equals("staging") %>'>

					<%
					String errorMessageKey = StringPool.BLANK;

					Group stagingGroup = themeDisplay.getScopeGroup();
					Group liveGroup = stagingGroup.getLiveGroup();

					Layout targetLayout = null;

					if (!controlPanel) {
						if (liveGroup == null) {
							errorMessageKey = "this-portlet-is-placed-in-a-page-that-does-not-exist-in-the-live-site-publish-the-page-first";
						}
						else {
							try {
								if (stagingGroup.isLayout()) {
									targetLayout = LayoutLocalServiceUtil.getLayout(liveGroup.getClassPK());
								}
								else {
									targetLayout = LayoutLocalServiceUtil.getLayoutByUuidAndGroupId(layout.getUuid(), liveGroup.getGroupId());
								}
							}
							catch (NoSuchLayoutException nsle) {
								errorMessageKey = "this-portlet-is-placed-in-a-page-that-does-not-exist-in-the-live-site-publish-the-page-first";
							}

							if (targetLayout != null) {
								LayoutType layoutType = targetLayout.getLayoutType();

								if (!(layoutType instanceof LayoutTypePortlet) || !((LayoutTypePortlet)layoutType).hasPortletId(selPortlet.getPortletId())) {
									errorMessageKey = "this-portlet-has-not-been-added-to-the-live-page-publish-the-page-first";
								}
							}
						}
					}
					else if (stagingGroup.isLayout()) {
						if (liveGroup == null) {
							errorMessageKey = "a-portlet-is-placed-in-this-page-of-scope-that-does-not-exist-in-the-live-site-publish-the-page-first";
						}
						else {
							try {
								targetLayout = LayoutLocalServiceUtil.getLayout(liveGroup.getClassPK());
							}
							catch (NoSuchLayoutException nsle) {
								errorMessageKey = "a-portlet-is-placed-in-this-page-of-scope-that-does-not-exist-in-the-live-site-publish-the-page-first";
							}
						}
					}
					%>

					<c:choose>
						<c:when test="<%= Validator.isNull(errorMessageKey) %>">

						<%
						boolean workflowEnabled = liveGroup.isWorkflowEnabled();

						TasksProposal proposal = null;

						if (workflowEnabled) {
							try {
								proposal = TasksProposalLocalServiceUtil.getProposal(Portlet.class.getName(), selPortletPrimaryKey);
							}
							catch (NoSuchProposalException nspe) {
							}
						}
						%>

							<aui:fieldset>
								<aui:field-wrapper label="what-would-you-like-to-copy-from-live-or-publish-to-live">
									<%@ include file="/html/portlet/portlet_configuration/export_import_options.jspf" %>
								</aui:field-wrapper>

								<c:choose>
									<c:when test="<%= workflowEnabled %>">
										<c:if test="<%= proposal == null %>">

											<%
											PortletURL proposePublicationURL = new PortletURLImpl(request, PortletKeys.LAYOUT_MANAGEMENT, layout.getPlid(), PortletRequest.ACTION_PHASE);

											proposePublicationURL.setPortletMode(PortletMode.VIEW);

											proposePublicationURL.setParameter("struts_action", "/layout_management/edit_proposal");
											proposePublicationURL.setParameter(Constants.CMD, Constants.ADD);
											proposePublicationURL.setParameter("redirect", currentURL);
											proposePublicationURL.setParameter("groupId", String.valueOf(liveGroup.getGroupId()));
											proposePublicationURL.setParameter("className", Portlet.class.getName());
											proposePublicationURL.setParameter("classPK", selPortletPrimaryKey);

											String[] workflowRoleNames = StringUtil.split(liveGroup.getWorkflowRoleNames());

											JSONArray jsonReviewers = JSONFactoryUtil.createJSONArray();

											Role role = RoleLocalServiceUtil.getRole(company.getCompanyId(), workflowRoleNames[0]);

											LinkedHashMap userParams = new LinkedHashMap();

											if (liveGroup.isOrganization()) {
												userParams.put("usersOrgs", new Long(liveGroup.getOrganizationId()));
											}
											else {
												userParams.put("usersGroups", new Long(liveGroup.getGroupId()));
											}

											userParams.put("userGroupRole", new Long[] {new Long(liveGroup.getGroupId()), new Long(role.getRoleId())});

											List<User> reviewers = UserLocalServiceUtil.search(company.getCompanyId(), null, null, userParams, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);

											if (reviewers.isEmpty()) {
												if (liveGroup.isCommunity()) {
													role = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.COMMUNITY_OWNER);
												}
												else {
													role = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.ORGANIZATION_OWNER);
												}

												userParams.put("userGroupRole", new Long[] {new Long(liveGroup.getGroupId()), new Long(role.getRoleId())});

												reviewers = UserLocalServiceUtil.search(company.getCompanyId(), null, null, userParams, QueryUtil.ALL_POS, QueryUtil.ALL_POS, (OrderByComparator)null);
											}

											for (User reviewer : reviewers) {
												JSONObject jsonReviewer = JSONFactoryUtil.createJSONObject();

												jsonReviewer.put("userId", reviewer.getUserId());
												jsonReviewer.put("fullName", HtmlUtil.escape(reviewer.getFullName()));

												jsonReviewers.put(jsonReviewer);
											}
											%>

											<aui:button-row>
												<aui:button onClick='<%= renderResponse.getNamespace() + "proposePublication();" %>' value="propose-publication" />

												<aui:button onClick='<%= renderResponse.getNamespace() + "copyFromLive();" %>' value="copy-from-live" />
											</aui:button-row>

											<aui:script>
												function <portlet:namespace />proposePublication() {
													Liferay.LayoutExporter.proposeLayout(
														{
															namespace: '<%= PortalUtil.getPortletNamespace(PortletKeys.LAYOUT_MANAGEMENT) %>',
															reviewers: <%= StringUtil.replace(jsonReviewers.toString(), '"', '\'') %>,
															title: '<liferay-ui:message key="proposal-description" />',
															url: '<%= proposePublicationURL.toString() %>'
														}
													);
												}
											</aui:script>
										</c:if>
									</c:when>
									<c:when test="<%= (themeDisplay.getURLPublishToLive() != null) || controlPanel %>">
										<aui:button-row>
											<aui:button onClick='<%= renderResponse.getNamespace() + "publishToLive();" %>' value="publish-to-live" />

											<aui:button onClick='<%= renderResponse.getNamespace() + "copyFromLive();" %>' value="copy-from-live" />
										</aui:button-row>
									</c:when>
								</c:choose>
							</aui:fieldset>
						</c:when>
						<c:otherwise>
							<liferay-ui:message key="<%= errorMessageKey %>" />
						</c:otherwise>
					</c:choose>
				</c:when>
			</c:choose>
		</aui:form>

		<aui:script use="aui-base,selector-css3">
			var toggleHandlerControl = function(item, index, collection) {
				var container = item.ancestor('.<portlet:namespace />handler-control').one('ul');

				if (container) {
					var action = 'hide';

					if (item.get('checked')) {
						action = 'show';
					}

					container[action]();
				}
			};

			var checkboxes = A.all('.<portlet:namespace />handler-control input[type=checkbox]');

			if (checkboxes) {
				var uncheckedBoxes = checkboxes.filter(':not(:checked)');

				if (uncheckedBoxes) {
					uncheckedBoxes.each(toggleHandlerControl);
				}

				checkboxes.detach('click');

				checkboxes.on(
					'click',
					function(event) {
						toggleHandlerControl(event.currentTarget);
					}
				);
			}
		</aui:script>
	</c:when>
	<c:otherwise>
		<%= LanguageUtil.format(locale, "the-x-portlet-does-not-have-any-data-that-can-be-exported-or-does-not-include-support-for-it", PortalUtil.getPortletTitle(selPortlet, application, locale)) %>
	</c:otherwise>
</c:choose>

<aui:script>
	function <portlet:namespace />copyFromLive() {
		if (confirm('<%= UnicodeLanguageUtil.get(pageContext, "are-you-sure-you-want-to-copy-from-live-and-update-the-existing-staging-portlet-information") %>')) {
			document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "copy_from_live";

			submitForm(document.<portlet:namespace />fm);
		}
	}

	function <portlet:namespace />exportData() {
		document.<portlet:namespace />fm.encoding = "multipart/form-data";

		document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "export";

		submitForm(document.<portlet:namespace />fm, '<portlet:actionURL windowState="<%= LiferayWindowState.EXCLUSIVE.toString() %>"><portlet:param name="struts_action" value="/portlet_configuration/export_import" /></portlet:actionURL>&etag=0', false);
	}

	function <portlet:namespace />importData() {
		document.<portlet:namespace />fm.encoding = "multipart/form-data";

		document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "import";

		submitForm(document.<portlet:namespace />fm);
	}

	function <portlet:namespace />publishToLive() {
		if (confirm('<%= UnicodeLanguageUtil.get(pageContext, "are-you-sure-you-want-to-publish-to-live-and-update-the-existing-portlet-data") %>')) {
			document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "publish_to_live";

			submitForm(document.<portlet:namespace />fm);
		}
	}

	Liferay.provide(
		window,
		'<portlet:namespace />toggleChildren',
		function(checkbox, parentDivId) {
			var A = AUI();

			var parentDiv = A.one('#' + parentDivId);

			var enabled = checkbox.checked;

			if (parentDiv) {
				parentDiv.all('input').each(
					function(item, index, collection) {
						var disabled = !enabled;

						if (enabled && item.hasClass('disabled')) {
							disabled = true;
						}

						item.set('disabled', disabled);
					}
				);
			}
		},
		['aui-base']
	);
</aui:script>