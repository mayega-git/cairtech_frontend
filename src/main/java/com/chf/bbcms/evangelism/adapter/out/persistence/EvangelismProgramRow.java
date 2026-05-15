package com.chf.bbcms.evangelism.adapter.out.persistence;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.Instant;
import java.util.UUID;

@Table("bbcms_evangelism_program")
public class EvangelismProgramRow {
    @Id private UUID id;
    private String title;
    private String type;
    @Column("objective_believers") private int objectiveBelievers;
    @Column("total_preached") private int totalPreached;
    @Column("total_saved") private int totalSaved;
    @Column("total_encouraged") private int totalEncouraged;
    private String status;
    @Column("created_by") private UUID createdBy;
    @Column("created_at") private Instant createdAt;
    @Column("updated_by") private UUID updatedBy;
    @Column("updated_at") private Instant updatedAt;
    @Version              private Long version;

    public UUID getId() { return id; }                public void setId(UUID id) { this.id = id; }
    public String getTitle() { return title; }        public void setTitle(String t) { this.title = t; }
    public String getType() { return type; }          public void setType(String t) { this.type = t; }
    public int getObjectiveBelievers() { return objectiveBelievers; } public void setObjectiveBelievers(int o) { this.objectiveBelievers = o; }
    public int getTotalPreached() { return totalPreached; } public void setTotalPreached(int t) { this.totalPreached = t; }
    public int getTotalSaved() { return totalSaved; }  public void setTotalSaved(int t) { this.totalSaved = t; }
    public int getTotalEncouraged() { return totalEncouraged; } public void setTotalEncouraged(int t) { this.totalEncouraged = t; }
    public String getStatus() { return status; }      public void setStatus(String s) { this.status = s; }
    public UUID getCreatedBy() { return createdBy; }  public void setCreatedBy(UUID c) { this.createdBy = c; }
    public Instant getCreatedAt() { return createdAt; } public void setCreatedAt(Instant c) { this.createdAt = c; }
    public UUID getUpdatedBy() { return updatedBy; }  public void setUpdatedBy(UUID u) { this.updatedBy = u; }
    public Instant getUpdatedAt() { return updatedAt; } public void setUpdatedAt(Instant u) { this.updatedAt = u; }
    public Long getVersion() { return version; }      public void setVersion(Long v) { this.version = v; }
}
