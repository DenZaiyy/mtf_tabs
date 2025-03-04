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

class Mtf_Tabs extends Module
{
    public function __construct()
    {
        $this->name = 'mtf_tabs';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'MTFibertech';
        $this->need_instance = 0;
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('MTF Tabs');
        $this->description = $this->l('Creates a main tab for all MTF modules');
        $this->ps_versions_compliancy = ['min' => '8.0.0', 'max' => _PS_VERSION_];
    }

    /**
     * Install the module
     */
    public function install()
    {
        return parent::install() && $this->installTabs();
    }

    /**
     * Uninstall the module
     */
    public function uninstall()
    {
        return parent::uninstall() && $this->uninstallTabs();
    }

    /**
     * Install the main MTF tab
     */
    public function installTabs()
    {
        // Create the parent tab first
        $mainTab = new Tab();
        $mainTab->active = 1;
        $mainTab->class_name = 'AdminMTFModules';
        $mainTab->name = [];

        foreach (Language::getLanguages(true) as $lang) {
            $mainTab->name[$lang['id_lang']] = 'MTF Modules';
        }

        $mainTab->id_parent = 0; // Root level tab
        $mainTab->module = $this->name;

        if (!$mainTab->add()) {
            return false;
        }

        $mainTabId = $mainTab->id;

        // 2. Create the Dashboard tab under the main tab
        $dashboardTab = new Tab();
        $dashboardTab->active = 1;
        $dashboardTab->class_name = 'AdminMTFDashboard';
        $dashboardTab->name = [];

        foreach (Language::getLanguages(true) as $lang) {
            $dashboardTab->name[$lang['id_lang']] = 'Dashboard';
        }

        $dashboardTab->id_parent = $mainTabId;
        $dashboardTab->module = $this->name;

        if (!$dashboardTab->add()) {
            return false;
        }

        // 3. Create the "MTF Configure" tab under the main tab
        $configureTab = new Tab();
        $configureTab->active = 1;
        $configureTab->class_name = 'AdminMTFConfigure';
        $configureTab->icon = "settings";
        $configureTab->name = [];

        foreach (Language::getLanguages(true) as $lang) {
            $configureTab->name[$lang['id_lang']] = 'MTF Configure';
        }

        $configureTab->id_parent = $mainTabId;
        $configureTab->module = $this->name;

        if (!$configureTab->add()) {
            return false;
        }

        // Save the IDs for later use
        Configuration::updateValue('MTF_TABS_PARENT_ID', $mainTabId);
        Configuration::updateValue('MTF_TABS_CONFIGURE_ID', $configureTab->id);

        return true;
    }

    /**
     * Uninstall tabs
     */
    public function uninstallTabs()
    {
        $tabRepository = $this->get('prestashop.core.admin.tab.repository');

        // First try to find and delete all child tabs
        try {
            $allTabs = Tab::getTabs($this->context->language->id);

            // Get the parent tab ID
            $parentTab = $tabRepository->findOneByClassName('AdminMTFModules');
            if (!$parentTab) {
                return true; // Nothing to uninstall
            }

            $parentTabId = $parentTab->getId();

            // Find all child tabs
            $childTabs = array_filter($allTabs, function ($tab) use ($parentTabId) {
                return (int)$tab['id_parent'] === (int)$parentTabId;
            });

            // Delete each child tab
            foreach ($childTabs as $childTab) {
                $tab = new Tab($childTab['id_tab']);
                $tab->delete();
            }

            // Finally delete the parent tab
            $tab = new Tab($parentTabId);
            $tab->delete();
        } catch (Exception $e) {
            // Silently fail
        }

        return true;
    }

    /**
     * Get the ID of the Configure tab
     */
    public static function getConfigureTabId()
    {
        return (int)Configuration::get('MTF_TABS_CONFIGURE_ID');
    }

    /**
     * Get the ID of the main parent tab
     */
    public static function getParentTabId()
    {
        return (int)Configuration::get('MTF_TABS_PARENT_ID');
    }
}
