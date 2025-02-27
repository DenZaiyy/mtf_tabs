<?php

/**
 * 2007-2025 PrestaShop
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 *
 * @author    Your Name <your.email@domain.com>
 * @copyright 2007-2025 Your Company
 * @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */

if (!defined('_PS_VERSION_')) {
    exit;
}

class AdminMTFDashboardController extends ModuleAdminController
{
    public function __construct()
    {
        $this->bootstrap = true;

        parent::__construct();

        $this->meta_title = $this->l('MTF Modules Dashboard');

        // Remove default actions
        $this->actions = [];
        $this->list_no_link = true;
    }

    /**
     * Fix for method signature to match parent class
     * @param bool $isNewTheme
     */
    public function setMedia($isNewTheme = false)
    {
        parent::setMedia($isNewTheme);
    }

    /**
     * Simpler approach to render the dashboard once
     */
    public function initContent()
    {
        // Call parent init to setup the page properly
        parent::initContent();

        // Get all modules that have registered tabs under the MTF parent
        $mtfModules = $this->getMTFModules();

        // Assign template variables
        $this->context->smarty->assign([
            'mtf_modules' => $mtfModules,
            'link' => $this->context->link
        ]);

        // Use the fetch method directly to get the template content
        $content = $this->context->smarty->fetch(
            $this->module->getLocalPath() . 'views/templates/admin/dashboard.tpl'
        );

        // Replace the entire page content with our template
        $this->context->smarty->assign('content', $content);
    }

    /**
     * Get all modules that have registered tabs under the MTF parent
     */
    private function getMTFModules()
    {
        $modules = [];

        try {
            // Get the parent tab ID using TabRepository service
            $tabRepository = $this->get('prestashop.core.admin.tab.repository');
            $parentTab = $tabRepository->findOneByClassName('AdminMTFModules');

            if (!$parentTab) {
                return $modules;
            }

            // Get all tabs
            $allTabs = Tab::getTabs($this->context->language->id);
            $parentTabId = $parentTab->getId();

            // Filter tabs by parent ID
            $childTabs = array_filter($allTabs, function ($tab) use ($parentTabId) {
                return (int)$tab['id_parent'] === (int)$parentTabId;
            });

            foreach ($childTabs as $tab) {
                // Skip the dashboard tab itself
                if ($tab['class_name'] == 'AdminMTFDashboard') {
                    continue;
                }

                // Only include tabs that are associated with a module
                $moduleName = $tab['module'];
                if (!empty($moduleName)) {
                    $moduleInstance = Module::getInstanceByName($moduleName);
                    if ($moduleInstance) {
                        $modules[] = [
                            'name' => $moduleName,
                            'displayName' => $moduleInstance->displayName,
                            'tab_name' => $tab['name'],
                            'tab_class' => $tab['class_name'],
                            'tab_link' => $this->context->link->getAdminLink($tab['class_name']),
                            'version' => $moduleInstance->version,
                            'active' => $moduleInstance->active,
                        ];
                    }
                }
            }
        } catch (Exception $e) {
            // Log error or handle it silently
        }

        return $modules;
    }
}
