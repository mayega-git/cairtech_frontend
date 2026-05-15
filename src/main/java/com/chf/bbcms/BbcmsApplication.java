package com.chf.bbcms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class BbcmsApplication {

    public static void main(String[] args) {
        SpringApplication.run(BbcmsApplication.class, args);
    }
}
