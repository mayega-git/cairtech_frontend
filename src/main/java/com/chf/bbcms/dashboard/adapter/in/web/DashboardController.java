package com.chf.bbcms.dashboard.adapter.in.web;

import com.chf.bbcms.attendance.domain.AcademicYears;
import com.chf.bbcms.dashboard.application.port.in.DashboardUseCase;
import com.chf.bbcms.dashboard.application.port.in.DashboardUseCase.BibleClubDashboard;
import com.chf.bbcms.dashboard.application.port.in.DashboardUseCase.NationalDashboard;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/dashboards")
public class DashboardController {

    private final DashboardUseCase useCase;

    public DashboardController(DashboardUseCase useCase) { this.useCase = useCase; }

    @GetMapping("/bible-clubs/{id}")
    @PreAuthorize("hasAuthority('bbcms:dashboard:bbc')")
    public Mono<BibleClubDashboard> bbcDashboard(@PathVariable UUID id,
                                                 @RequestParam(required = false) Integer academicYear) {
        int year = academicYear == null ? AcademicYears.current() : academicYear;
        return useCase.bibleClubDashboard(id, year);
    }

    @GetMapping("/national")
    @PreAuthorize("hasAuthority('bbcms:dashboard:national')")
    public Mono<NationalDashboard> national(@RequestParam(required = false) Integer academicYear) {
        int year = academicYear == null ? AcademicYears.current() : academicYear;
        return useCase.nationalDashboard(year);
    }
}
