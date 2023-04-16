﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using TalkTwoYou.Data;

#nullable disable

namespace TalkTwoYou.Migrations
{
    [DbContext(typeof(DataContext))]
    [Migration("20230214105815_tableRemakeV1")]
    partial class tableRemakeV1
    {
        /// <inheritdoc />
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "7.0.2")
                .HasAnnotation("Relational:MaxIdentifierLength", 128);

            SqlServerModelBuilderExtensions.UseIdentityColumns(modelBuilder);

            modelBuilder.Entity("TalkTwoYou.Models.DatabaseModels.RegisterStatus", b =>
                {
                    b.Property<Guid>("FullyRegistered")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("uniqueidentifier");

                    b.Property<int>("EmailCode")
                        .HasColumnType("int");

                    b.Property<Guid>("UserId")
                        .HasColumnType("uniqueidentifier");

                    b.Property<bool>("Verified")
                        .HasColumnType("bit");

                    b.HasKey("FullyRegistered");

                    b.HasIndex("UserId");

                    b.ToTable("RegisterStatus");
                });

            modelBuilder.Entity("TalkTwoYou.Models.DatabaseModels.UserDetails", b =>
                {
                    b.Property<Guid>("UserId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("uniqueidentifier");

                    b.Property<string>("Email")
                        .IsRequired()
                        .HasColumnType("varchar(200)");

                    b.Property<string>("FirebaseUid")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<string>("FirstName")
                        .IsRequired()
                        .HasColumnType("varchar(200)");

                    b.Property<string>("LastName")
                        .IsRequired()
                        .HasColumnType("varchar(200)");

                    b.Property<string>("Password")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.HasKey("UserId");

                    b.ToTable("UserDetails");
                });

            modelBuilder.Entity("TalkTwoYou.Models.DatabaseModels.UserRefreshTokens", b =>
                {
                    b.Property<Guid>("RefreshId")
                        .ValueGeneratedOnAdd()
                        .HasColumnType("uniqueidentifier");

                    b.Property<string>("RefreshToken")
                        .IsRequired()
                        .HasColumnType("nvarchar(max)");

                    b.Property<Guid>("UserId")
                        .HasColumnType("uniqueidentifier");

                    b.HasKey("RefreshId");

                    b.ToTable("UserRefreshTokens");
                });

            modelBuilder.Entity("TalkTwoYou.Models.DatabaseModels.RegisterStatus", b =>
                {
                    b.HasOne("TalkTwoYou.Models.DatabaseModels.UserDetails", "User")
                        .WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Cascade)
                        .IsRequired();

                    b.Navigation("User");
                });
#pragma warning restore 612, 618
        }
    }
}
