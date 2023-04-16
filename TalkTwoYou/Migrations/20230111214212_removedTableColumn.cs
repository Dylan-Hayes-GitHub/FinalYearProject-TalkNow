using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TalkTwoYou.Migrations
{
    /// <inheritdoc />
    public partial class removedTableColumn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FirebaseId",
                table: "UserDetails");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "FirebaseId",
                table: "UserDetails",
                type: "varchar(200)",
                nullable: false,
                defaultValue: "");
        }
    }
}
