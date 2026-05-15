package com.chf.bbcms.architecture;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.library.Architectures;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

/**
 * Garde-fous architecturaux pour l'architecture hexagonale BBCMS.
 * Le domain ne doit JAMAIS dépendre de Spring, Jakarta, JPA, R2DBC ou des couches externes.
 */
@AnalyzeClasses(packages = "com.chf.bbcms",
        importOptions = ImportOption.DoNotIncludeTests.class)
class HexagonalArchitectureTest {

    @ArchTest
    static final ArchRule domain_should_not_depend_on_spring =
            noClasses().that().resideInAPackage("..domain..")
                    .should().dependOnClassesThat().resideInAnyPackage(
                            "org.springframework..",
                            "jakarta.persistence..",
                            "io.r2dbc..",
                            "org.springframework.data..",
                            "org.springframework.web..");

    @ArchTest
    static final ArchRule domain_should_not_depend_on_adapters =
            noClasses().that().resideInAPackage("..domain..")
                    .should().dependOnClassesThat().resideInAPackage("..adapter..");

    @ArchTest
    static final ArchRule domain_should_not_depend_on_application =
            noClasses().that().resideInAPackage("..domain..")
                    .should().dependOnClassesThat().resideInAPackage("..application..");

    @ArchTest
    static final ArchRule application_should_not_depend_on_adapters =
            noClasses().that().resideInAPackage("..application..")
                    .should().dependOnClassesThat().resideInAPackage("..adapter..");

    /**
     * Le layered strict ne s'applique qu'aux modules métier — config/ et shared/outbox/
     * sont des packages transverses (wiring Spring, infrastructure d'événements) hors hexagone.
     */
    @ArchTest
    static final ArchRule layered_architecture =
            Architectures.layeredArchitecture()
                    .consideringOnlyDependenciesInLayers()
                    .layer("Domain").definedBy("..domain..")
                    .layer("Application").definedBy("..application..")
                    .layer("Adapter").definedBy("..adapter..")
                    .whereLayer("Adapter").mayNotBeAccessedByAnyLayer()
                    .whereLayer("Application").mayOnlyBeAccessedByLayers("Adapter")
                    .whereLayer("Domain").mayOnlyBeAccessedByLayers("Application", "Adapter");

    @ArchTest
    static final ArchRule controllers_should_be_in_adapter_in_web =
            classes().that().haveSimpleNameEndingWith("Controller")
                    .should().resideInAPackage("..adapter.in.web..");

    @ArchTest
    static final ArchRule services_should_be_in_application_service =
            classes().that().haveSimpleNameEndingWith("Service")
                    .and().resideInAPackage("com.chf.bbcms..")
                    .should().resideInAPackage("..application.service..");
}
