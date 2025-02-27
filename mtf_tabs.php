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
        return parent::install() && $this->installMainTab();
    }

    /**
     * Uninstall the module
     */
    public function uninstall()
    {
        return parent::uninstall() && $this->uninstallMainTab();
    }

    /**
     * Install the main MTF tab
     */
    public function installMainTab()
    {
        // Create the parent tab first
        $parentTab = new Tab();
        $parentTab->active = 1;
        $parentTab->class_name = 'AdminMTFModules';
        $parentTab->name = [];

        foreach (Language::getLanguages(true) as $lang) {
            $parentTab->name[$lang['id_lang']] = 'MTF Modules';
        }

        $parentTab->id_parent = 0; // Root level tab
        $parentTab->module = $this->name;

        $result = $parentTab->add();

        // Create a default dashboard tab
        if ($result) {
            // Get the parent tab ID using its ID directly
            $tabRepository = $this->get('prestashop.core.admin.tab.repository');
            $parentId = null;

            try {
                $tabParent = $tabRepository->findOneByClassName('AdminMTFModules');
                if ($tabParent) {
                    $parentId = $tabParent->getId();
                }
            } catch (Exception $e) {
                // Parent tab might not be available yet
                return false;
            }

            $dashboardTab = new Tab();
            $dashboardTab->active = 1;
            $dashboardTab->class_name = 'AdminMTFDashboard';
            $dashboardTab->name = [];

            foreach (Language::getLanguages(true) as $lang) {
                $dashboardTab->name[$lang['id_lang']] = 'Dashboard';
            }

            $dashboardTab->id_parent = $parentId;
            $dashboardTab->module = $this->name;

            return $dashboardTab->add();
        }

        return $result;
    }

    /**
     * Uninstall tabs
     */
    public function uninstallMainTab()
    {
        $tabRepository = $this->get('prestashop.core.admin.tab.repository');

        // First remove any child tabs
        try {
            $childTab = $tabRepository->findOneByClassName('AdminMTFDashboard');
            if ($childTab) {
                $tab = new Tab($childTab->getId());
                $tab->delete();
            }
        } catch (Exception $e) {
            // Child tab not found
        }

        // Then remove the parent tab
        try {
            $parentTab = $tabRepository->findOneByClassName('AdminMTFModules');
            if ($parentTab) {
                $tab = new Tab($parentTab->getId());
                return $tab->delete();
            }
        } catch (Exception $e) {
            // Parent tab not found
        }

        return true;
    }

    /**
     * Add a helper method that other modules can use to get the parent tab ID
     */
    public static function getParentTabId()
    {
        // Note: This static method won't work directly with the repository pattern
        // It's kept for backward compatibility but modules should use their own tab lookup
        return 0; // Fallback value
    }
}
