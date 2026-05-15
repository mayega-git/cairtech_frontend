package com.chf.bbcms.identity.adapter.in.web;

import com.chf.bbcms.identity.application.port.in.ManageUserAccountUseCase;
import com.chf.bbcms.identity.application.port.in.RegisterUserCommand;
import com.chf.bbcms.identity.domain.Gender;
import com.chf.bbcms.identity.domain.UserAccount;
import com.chf.bbcms.identity.domain.UserType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/bbcms/users")
public class UserAccountController {

    private final ManageUserAccountUseCase useCase;

    public UserAccountController(ManageUserAccountUseCase useCase) {
        this.useCase = useCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<UserAccountResponse> register(@Valid @RequestBody RegisterRequest req) {
        RegisterUserCommand command = new RegisterUserCommand(
                req.email(), req.password(), req.phone(),
                req.firstNames(), req.nextNames(), req.dateOfBirth(), req.gender(),
                req.locale(), req.requestedType(), req.bibleClubId(), req.levelId(),
                req.profession(), req.pictureFileId());
        return useCase.register(command).map(UserAccountResponse::from);
    }

    @PostMapping("/activate")
    public Mono<UserAccountResponse> activate(@RequestParam("token") String token) {
        return useCase.activateByToken(token).map(UserAccountResponse::from);
    }

    @GetMapping("/{id}")
    public Mono<ResponseEntity<UserAccountResponse>> get(@PathVariable UUID id) {
        return useCase.findById(id)
                .map(UserAccountResponse::from)
                .map(ResponseEntity::ok);
    }

    public record RegisterRequest(
            @NotBlank @Email String email,
            @NotBlank @Size(min = 8, max = 100) String password,
            String phone,
            @NotBlank String firstNames,
            String nextNames,
            LocalDate dateOfBirth,
            Gender gender,
            String locale,
            @NotNull UserType requestedType,
            UUID bibleClubId,
            UUID levelId,
            String profession,
            UUID pictureFileId
    ) {}

    public record UserAccountResponse(UUID id, String email, String status, String userType,
                                      String firstNames, String nextNames) {
        static UserAccountResponse from(UserAccount a) {
            return new UserAccountResponse(
                    a.getId(), a.getEmail(), a.getStatus().name(), a.getUserType().name(),
                    a.getProfile().firstNames(), a.getProfile().nextNames());
        }
    }
}
